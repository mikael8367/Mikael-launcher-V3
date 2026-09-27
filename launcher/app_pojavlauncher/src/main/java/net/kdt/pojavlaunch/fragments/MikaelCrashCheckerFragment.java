package net.kdt.pojavlaunch.fragments;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.fragment.app.Fragment;

import net.kdt.pojavlaunch.R;
import net.kdt.pojavlaunch.Tools;
import net.kdt.pojavlaunch.prefs.LauncherPreferences;
import net.kdt.pojavlaunch.value.launcherprofiles.LauncherProfiles;
import net.kdt.pojavlaunch.value.launcherprofiles.MinecraftProfile;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class MikaelCrashCheckerFragment extends Fragment {
    public static final String TAG="MIKAEL_CRASH_CHECKER";

    private TextView status;
    private TextView result;
    private Button analyze;
    private String currentReport="";

    private static final Pattern EXCEPTION =
            Pattern.compile("(?m)(?:^|\\n)(?:[\\w.$]+(?::|\\s+))?([A-Za-z_$][\\w$]*(?:Exception|Error|Fault|Failure)(?:: [^\\n]{0,500})?)");
    private static final Pattern CAUSED_BY =
            Pattern.compile("(?i)Caused by:\\s*([^\\n]{3,600})");
    private static final Pattern MOD_FILE =
            Pattern.compile("(?i)(?:Mod File|mod file|jar|filename|file)[:=]\\s*([^\\n]*?)(?:\\.jar)(?:[^\\n]*)");
    private static final Pattern FABRIC_MOD =
            Pattern.compile("(?i)(?:fabric.mod.json|modid|id)[:=]\\s*[\\"']?([a-z0-9_.-]{2,80})");
    private static final Pattern REQUIRED =
            Pattern.compile("(?i)(?:depends on|requires|requires minecraft|requires java|dependency)[:\\s]+([^\\n]{2,250})");
    private static final Pattern MC_VERSION =
            Pattern.compile("(?i)(?:minecraft(?: version)?|version id|game version)[^0-9]{0,32}(\\d+\\.\\d+(?:\\.\\d+)?)");
    private static final Pattern JAVA_VERSION =
            Pattern.compile("(?i)(?:java(?: version)?|runtime)[^0-9]{0,28}((?:1\\.)?\\d+)(?:[._-]\\d+)*");
    private static final Pattern MEMORY =
            Pattern.compile("(?i)(?:heap|memory)[^0-9]{0,30}(\\d+)\\s*(mb|gb)");

    private static final class Evidence {
        final String source;
        final String line;
        Evidence(String source,String line){this.source=source;this.line=line;}
    }

    private static final class Finding {
        String id,title,cause,fix,stage;
        int score;
        final List<Evidence> evidence=new ArrayList<>();
        final Set<String> modules=new LinkedHashSet<>();
        final Set<String> dependencies=new LinkedHashSet<>();
        Finding(String id,String title,String cause,String fix,String stage){
            this.id=id;this.title=title;this.cause=cause;this.fix=fix;this.stage=stage;
        }
    }

    private static final class ReportFile {
        final File file;
        final String text;
        final String lower;
        ReportFile(File f,String t){file=f;text=t;lower=t.toLowerCase(Locale.ROOT);}
    }

    private static final class Analysis {
        String summary;
        String report;
        Analysis(String s,String r){summary=s;report=r;}
    }

    public MikaelCrashCheckerFragment(){super(R.layout.fragment_mikael_crash_checker);}

    @Override public void onViewCreated(@NonNull View v,@Nullable Bundle b){
        status=v.findViewById(R.id.crash_status);
        result=v.findViewById(R.id.crash_result);
        analyze=v.findViewById(R.id.crash_analyze);
        Button copy=v.findViewById(R.id.crash_copy);
        Button share=v.findViewById(R.id.crash_share);
        Button back=v.findViewById(R.id.crash_back);

        analyze.setOnClickListener(x->runAnalysis());
        copy.setOnClickListener(x->copyReport());
        share.setOnClickListener(x->shareReport());
        back.setOnClickListener(x->Tools.swapFragment(requireActivity(),MainMenuFragment.class,MainMenuFragment.TAG,null));

        runAnalysis();
    }

    private void runAnalysis(){
        status.setText("ANALISADOR AVANÇADO: lendo logs e cruzando evidências...");
        result.setText("Aguarde...");
        analyze.setEnabled(false);
        new Thread(()->{
            try{
                Analysis a=analyzeCrash();
                android.app.Activity activity=getActivity();
                if(activity!=null) activity.runOnUiThread(()->{
                    if(!isAdded())return;
                    currentReport=a.report;
                    status.setText(a.summary);
                    result.setText(a.report);
                    analyze.setEnabled(true);
                });
            }catch(Exception e){
                android.app.Activity activity=getActivity();
                if(activity!=null) activity.runOnUiThread(()->{
                    if(!isAdded())return;
                    status.setText("Falha no analisador");
                    result.setText("Erro técnico do analisador:\n"+e.getClass().getSimpleName()+": "+e.getMessage());
                    analyze.setEnabled(true);
                });
            }
        }).start();
    }

    private Analysis analyzeCrash() throws Exception{
        File dir=getCurrentProfileDirectory();
        List<File> files=findCandidateFiles(dir);
        if(files.isEmpty()){
            return new Analysis("SEM DADOS",
                    "VERIFICAR CRASH\n\nNão há logs/crash-reports disponíveis para análise.\n\n"+
                    "Faça o Minecraft iniciar até acontecer o crash, volte ao launcher e execute a análise imediatamente.");
        }

        ReportFile primary=null;
        List<ReportFile> reports=new ArrayList<>();
        for(File f:files){
            try{
                String t=readTail(f,320000);
                if(t.trim().isEmpty())continue;
                ReportFile r=new ReportFile(f,t);
                reports.add(r);
                if(primary==null) primary=r;
            }catch(Exception ignored){}
        }
        if(reports.isEmpty()){
            return new Analysis("ARQUIVOS ILEGÍVEIS",
                    "Encontrei arquivos de log, mas não consegui ler o conteúdo.");
        }

        List<ReportFile> strongest=new ArrayList<>(reports);
        Collections.sort(strongest,(a,b)->Long.compare(b.file.lastModified(),a.file.lastModified()));
        primary=strongest.get(0);

        List<Finding> findings=detectFindings(reports,primary);
        Collections.sort(findings,(a,b)->Integer.compare(b.score,a.score));

        String minecraft=firstMatch(MC_VERSION,primary.text);
        String java=firstMatch(JAVA_VERSION,primary.text);
        String loader=detectLoader(primary.lower);
        String stage=detectStage(primary.lower);
        String offender=detectOffendingModule(primary.text);
        String deepest=deepestCause(primary.text);
        String topError=lastException(primary.text);

        RuntimeInfo runtime=getRuntimeInfo();
        StorageInfo storage=getStorageInfo(dir);

        int topScore=findings.isEmpty()?0:findings.get(0).score;
        int confidence=confidence(findings,primary,offender,deepest);
        String verdict=findings.isEmpty()?"CAUSA NÃO DETERMINADA":findings.get(0).title;

        StringBuilder out=new StringBuilder();
        out.append("══════════════════════════════\n");
        out.append("MIKAEL CRASH CHECKER • DIAGNÓSTICO PRO\n");
        out.append("══════════════════════════════\n\n");

        out.append("RESUMO\n");
        out.append("Diagnóstico: ").append(verdict).append("\n");
        out.append("Confiança: ").append(confidence).append("/100\n");
        out.append("Etapa do crash: ").append(stage).append("\n");
        out.append("Arquivo principal: ").append(primary.file.getName()).append("\n");
        out.append("Arquivos cruzados: ").append(reports.size()).append("\n\n");

        out.append("AMBIENTE DETECTADO\n");
        if(minecraft!=null)out.append("Minecraft: ").append(minecraft).append("\n");
        out.append("Loader: ").append(loader).append("\n");
        if(java!=null)out.append("Java no log: ").append(java).append("\n");
        out.append("RAM disponível agora: ").append(runtime.availableMb).append(" MB\n");
        out.append("RAM total: ").append(runtime.totalMb).append(" MB\n");
        out.append("RAM alocada ao Minecraft: ").append(runtime.allocatedMb).append(" MB\n");
        out.append("Espaço livre: ").append(storage.freeMb).append(" MB\n");
        out.append("Mods instalados: ").append(storage.modCount).append("\n\n");

        if(offender!=null) out.append("MOD/ARQUIVO SUSPEITO\n").append(offender).append("\n\n");
        if(deepest!=null) out.append("CAUSA MAIS PROFUNDA ENCONTRADA\n").append(deepest).append("\n\n");
        if(topError!=null) out.append("ÚLTIMA EXCEÇÃO RELEVANTE\n").append(topError).append("\n\n");

        if(findings.isEmpty()){
            out.append("POR QUE NÃO DEU PARA DECIDIR\n");
            out.append("O log não contém uma assinatura suficientemente específica. O analisador evita apontar Forge/OptiFine/GPU apenas porque o nome apareceu no log.\n\n");
            out.append("PRÓXIMOS PASSOS\n");
            out.append("1. Rode novamente e analise o arquivo criado pelo crash.\n");
            out.append("2. Teste sem mods para separar problema do Minecraft de problema de mod.\n");
            out.append("3. Compare com outra runtime Java compatível.\n");
        }else{
            Finding best=findings.get(0);
            out.append("O QUE ACONTECEU\n").append(best.cause).append("\n\n");
            out.append("COMO RESOLVER\n").append(best.fix).append("\n\n");

            out.append("EVIDÊNCIAS FORTES\n");
            for(Evidence e:best.evidence)
                out.append("• [").append(e.source).append("] ").append(e.line).append("\n");

            if(!best.modules.isEmpty()){
                out.append("\nMODS RELACIONADOS\n");
                for(String m:best.modules)out.append("• ").append(m).append("\n");
            }
            if(!best.dependencies.isEmpty()){
                out.append("\nDEPENDÊNCIAS CITADAS\n");
                for(String d:best.dependencies)out.append("• ").append(d).append("\n");
            }

            if(findings.size()>1){
                out.append("\nHIPÓTESES SECUNDÁRIAS\n");
                for(int i=1;i<Math.min(5,findings.size());i++){
                    Finding f=findings.get(i);
                    out.append(i+1).append(". ").append(f.title)
                       .append(" — força ").append(f.score).append("/100");
                    if(f.stage!=null)out.append(" • etapa: ").append(f.stage);
                    out.append("\n");
                }
            }
        }

        out.append("\nANÁLISE DE CONSISTÊNCIA\n");
        out.append(consistencyReport(findings,reports,primary,offender));
        out.append("\n\nARQUIVOS ANALISADOS\n");
        for(int i=0;i<Math.min(8,reports.size());i++)
            out.append("• ").append(reports.get(i).file.getName()).append("\n");

        out.append("\nNOTA\n");
        out.append("O diagnóstico é heurístico: ele cruza exceções, contexto, dependências, nomes de mods e repetição entre arquivos. Não trata uma palavra genérica isolada como prova de causa.");

        return new Analysis(confidence>=75?"Diagnóstico forte: "+verdict:
                confidence>=50?"Diagnóstico provável: "+verdict:"Diagnóstico inconclusivo: "+verdict,out.toString());
    }

    private List<Finding> detectFindings(List<ReportFile> reports,ReportFile primary){
        Map<String,Finding> map=new LinkedHashMap<>();

        register(map,"oom","Memória insuficiente","A JVM encontrou sinais de falta de heap/memória nativa ou não conseguiu criar recursos por falta de memória.",
                "Diminua a RAM alocada se o Android estiver sem memória; feche apps; desative shaders/mods pesados. Só aumente a RAM do Minecraft quando houver RAM livre suficiente.",
                "Inicialização/Jogo");
        register(map,"java","Java incompatível","Há evidências explícitas de versão de Java incompatível com classes, o Minecraft ou um componente.",
                "Instale a runtime Java compatível com a versão do Minecraft e associe a runtime correta ao perfil. Não escolha Java apenas pelo número mais alto.",
                "Inicialização");

        register(map,"missing","Dependência ou mod ausente","O loader relata que um mod depende de outro componente que não está disponível.",
                "Instale a dependência indicada ou remova o mod que a exige. Use versões destinadas à mesma versão de Minecraft e ao mesmo loader.",
                "Carregamento de mods");
        register(map,"mixin","Conflito de Mixin","O stacktrace mostra falha de injection/mixin; isso costuma apontar para incompatibilidade entre mods, Minecraft e loader.",
                "Atualize o mod citado para a versão exata do Minecraft/loader. Se começou após instalar um mod, teste removendo esse mod primeiro.",
                "Carregamento de mods");
        register(map,"class","Classe/API incompatível","Uma classe, método ou campo esperado por um mod não existe na combinação atual.",
                "Alinhe a versão do mod, loader e Minecraft. O nome do mod antes do stacktrace é a primeira coisa a conferir.",
                "Carregamento de mods");
        register(map,"forge","Falha específica do Forge","Há uma assinatura explícita de carregamento do Forge, modlauncher ou FML junto de erro concreto.",
                "Use um Forge compatível com a versão do Minecraft e verifique as dependências dos mods.",
                "Carregamento de mods");
        register(map,"fabric","Falha específica do Fabric","Há assinatura do Fabric Loader/API associada a erro de carregamento ou dependência.",
                "Use Fabric Loader/Fabric API da mesma linha do Minecraft e confirme as dependências dos mods.",
                "Carregamento de mods");
        register(map,"render","Falha gráfica/OpenGL/Vulkan/Zink","Há erro concreto de criação de contexto gráfico, shader, OpenGL, Vulkan, EGL ou biblioteca gráfica nativa.",
                "Desative shaders e opções gráficas experimentais; teste renderer alternativo/Zink quando disponível; compare com uma instância vanilla.",
                "Inicialização gráfica");
        register(map,"lwjgl","Falha nativa LWJGL/GLFW","Uma biblioteca nativa gráfica não conseguiu carregar/inicializar corretamente.",
                "Teste outro renderer e outra runtime compatível; verifique conflitos de bibliotecas nativas e remova mods gráficos para isolar o problema.",
                "Inicialização gráfica");
        register(map,"native","Crash nativo","Há sinais de SIGSEGV, SIGABRT ou fatal signal; o processo terminou dentro de código nativo.",
                "Isole renderer, LWJGL, shaders e mods gráficos. Compare com vanilla e, se necessário, outra runtime compatível.",
                "Código nativo");
        register(map,"auth","Autenticação inválida","O log mostra falha de sessão/token/username/serviço de autenticação.",
                "Refaça o login, confirme a conta e a sessão. Para serviços alternativos, confirme a integração de autenticação exigida pelo servidor.",
                "Login");
        register(map,"network","Falha de rede/download","Há erro explícito de DNS, timeout, conexão, SSL ou HTTP durante download/acesso remoto.",
                "Verifique internet, DNS e disponibilidade do servidor. Repita o download e confirme se o erro aparece novamente.",
                "Download/Rede");
        register(map,"storage","Armazenamento insuficiente","Há evidência de falta de espaço ou erro de leitura/gravação do armazenamento.",
                "Libere espaço e tente novamente. Evite mover o diretório do jogo durante downloads ou instalação.",
                "Arquivos");
        register(map,"jar","JAR/biblioteca corrompido","O log acusa JAR inválido, ZIP corrompido ou biblioteca que não pode ser lida.",
                "Rebaixe somente o JAR indicado. Se ele continuar falhando, remova o arquivo específico e deixe o launcher baixá-lo novamente.",
                "Bibliotecas");
        register(map,"optifine","Conflito envolvendo OptiFine","Há uma assinatura específica de OptiFine associada a erro, não apenas a presença do nome.",
                "Use uma versão estável de OptiFine para o Minecraft atual e teste sem shaders/mods de renderização conflitantes.",
                "Renderização");
        register(map,"permission","Permissão de arquivo","O processo não conseguiu ler/gravar um arquivo por permissão ou filesystem somente leitura.",
                "Confira permissões do aplicativo, espaço livre e se o diretório do jogo está gravável.",
                "Arquivos");

        for(ReportFile r:reports)scoreReport(map,r);
        enrichWithPrimaryEvidence(map,primary);
        return new ArrayList<>(map.values());
    }

    private void register(Map<String,Finding> map,String id,String title,String cause,String fix,String stage){
        map.put(id,new Finding(id,title,cause,fix,stage));
    }

    private void scoreReport(Map<String,Finding> map,ReportFile r){
        String l=r.lower;
        Finding f;

        f=map.get("oom");
        score(f,r,l,new String[]{"outofmemoryerror","java heap space","gc overhead limit exceeded","unable to create native thread","failed to allocate"},16);

        f=map.get("java");
        score(f,r,l,new String[]{"unsupportedclassversionerror","class file version","unsupported major.minor","could not create the java virtual machine"},18);

        f=map.get("missing");
        score(f,r,l,new String[]{"modresolutionexception","could not find required mod","missing dependency","depends on","required mod"},11);

        f=map.get("mixin");
        score(f,r,l,new String[]{"mixinapplyerror","invalid injection","injectionpoint","callback method","mixin transformation failed"},14);

        f=map.get("class");
        score(f,r,l,new String[]{"noclassdeffounderror","classnotfoundexception","nosuchmethoderror","nosuchfielderror","abstractmethoderror"},13);

        f=map.get("forge");
        score(f,r,l,new String[]{"fml loading error","modlauncher.*error","net.minecraftforge","forge mod loading has failed"},8);
        // Generic "forge" alone is deliberately ignored.

        f=map.get("fabric");
        score(f,r,l,new String[]{"fabricloader","fabric loader","modresolutionexception.*fabric","net.fabricmc.loader.impl.launch"},8);

        f=map.get("render");
        score(f,r,l,new String[]{"egl_bad","egl error","opengl error","glfw error","vulkan error","shader compilation failed","zink.*error"},13);

        f=map.get("lwjgl");
        score(f,r,l,new String[]{"org.lwjgl","liblwjgl","glfw","unsatisfiedlinkerror.*lwjgl","native library.*lwjgl"},12);

        f=map.get("native");
        score(f,r,l,new String[]{"sigsegv","sigabrt","fatal signal 11","fatal signal 6","native crash","signal 11"},19);

        f=map.get("auth");
        score(f,r,l,new String[]{"invalid session","failed to verify username","authenticationservers","access token invalid","minecraft authentication failed"},12);

        f=map.get("network");
        score(f,r,l,new String[]{"unknownhostexception","connectexception","connection reset","sockettimeoutexception","sslhandshakeexception","http 403","http 404","failed to download"},10);

        f=map.get("storage");
        score(f,r,l,new String[]{"no space left on device","enospc","disk full","storage full"},18);

        f=map.get("jar");
        score(f,r,l,new String[]{"zipexception","zip end header not found","invalid or corrupt jarfile","jar hell","failed to load jar"},15);

        f=map.get("optifine");
        score(f,r,l,new String[]{"optifine.*exception","optifine.*error","optifine.*failed","optifine.*crash"},12);

        f=map.get("permission");
        score(f,r,l,new String[]{"permission denied","eacces","read-only file system"},13);

        for(Finding x:map.values()){
            if(x.score>100)x.score=100;
            extractEntities(x,r);
        }
    }

    private void score(Finding f,ReportFile r,String lower,String[] signatures,int weight){
        if(f==null)return;
        for(String sig:signatures){
            try{
                if(Pattern.compile(sig).matcher(lower).find()){
                    f.score=Math.min(100,f.score+weight);
                    addEvidence(f,r,sig);
                }
            }catch(Exception ignored){}
        }
    }

    private void addEvidence(Finding f,ReportFile r,String sig){
        if(f.evidence.size()>=6)return;
        try{
            Matcher m=Pattern.compile(sig).matcher(r.lower);
            if(!m.find())return;
            int i=m.start();
            String raw=r.text.substring(Math.max(0,i-180),Math.min(r.text.length(),i+500)).replace('\n',' ');
            raw=raw.replaceAll("\\s+"," ").trim();
            f.evidence.add(new Evidence(r.file.getName(),raw));
        }catch(Exception ignored){}
    }

    private void extractEntities(Finding f,ReportFile r){
        Matcher m=MOD_FILE.matcher(r.text);
        while(m.find() && f.modules.size()<12)f.modules.add(m.group(1).trim()+".jar");
        m=FABRIC_MOD.matcher(r.text);
        while(m.find() && f.modules.size()<12)f.modules.add(m.group(1).trim());
        m=REQUIRED.matcher(r.text);
        while(m.find() && f.dependencies.size()<12)f.dependencies.add(m.group(1).trim());
    }

    private void enrichWithPrimaryEvidence(Map<String,Finding> map,ReportFile r){
        // Cross-correlation bonus: a concrete exception plus the same signature
        // in another report is stronger than a single generic mention.
        Map<String,Integer> fileHits=new HashMap<>();
        for(Finding f:map.values()){
            int files=0;
            for(Evidence e:f.evidence)if(e.source!=null)files++;
            fileHits.put(f.id,files);
            if(f.score>0 && files>=2)f.score=Math.min(100,f.score+8);
        }
        // Penalize broad findings when there is a stronger concrete exception.
        boolean concrete=false;
        for(Finding f:map.values())if(f.score>=25 && !"forge".equals(f.id) && !"fabric".equals(f.id))concrete=true;
        if(concrete){
            Finding forge=map.get("forge");
            Finding fabric=map.get("fabric");
            if(forge!=null && forge.score<20)forge.score=Math.max(0,forge.score-5);
            if(fabric!=null && fabric.score<20)fabric.score=Math.max(0,fabric.score-5);
        }
    }

    private String consistencyReport(List<Finding> findings,List<ReportFile> reports,ReportFile primary,String offender){
        if(findings.isEmpty())return "Nenhuma assinatura forte foi confirmada.";
        Finding best=findings.get(0);
        int evidence=best.evidence.size();
        int files=new HashSet<String>(){{for(Evidence e:best.evidence)add(e.source);}}.size();
        StringBuilder s=new StringBuilder();
        s.append("Hipótese líder: ").append(best.title).append(". ");
        s.append("Evidências fortes: ").append(evidence).append(". ");
        if(files>=2)s.append("A mesma categoria aparece em múltiplos arquivos. ");
        else s.append("A assinatura principal aparece em um arquivo. ");
        if(offender!=null)s.append("Há um alvo concreto: ").append(offender).append(". ");
        if(best.score>=70)s.append("A pontuação indica evidência forte.");
        else if(best.score>=45)s.append("A pontuação indica evidência moderada.");
        else s.append("A pontuação ainda é limitada; confirme removendo o componente suspeito.");
        return s.toString();
    }

    private int confidence(List<Finding> fs,ReportFile p,String offender,String deepest){
        if(fs.isEmpty())return 15;
        int score=fs.get(0).score;
        if(deepest!=null)score+=8;
        if(offender!=null)score+=8;
        if(fs.size()>1 && fs.get(1).score>=45)score-=5;
        return Math.max(20,Math.min(98,score));
    }

    private String detectOffendingModule(String t){
        Matcher m=MOD_FILE.matcher(t);
        String last=null;
        while(m.find())last=m.group(1).trim()+".jar";
        if(last!=null)return last;
        m=FABRIC_MOD.matcher(t);
        if(m.find())return m.group(1);
        String[] keys={"MixinApplyError","NoSuchMethodError","NoClassDefFoundError","ModLoadingException"};
        for(String k:keys){
            int i=t.indexOf(k);
            if(i>=0){
                String snippet=t.substring(Math.max(0,i-260),Math.min(t.length(),i+500)).replace('\n',' ');
                Matcher pm=Pattern.compile("(?i)([a-z0-9_.-]{2,80}\.jar)").matcher(snippet);
                if(pm.find())return pm.group(1);
            }
        }
        return null;
    }

    private String deepestCause(String t){
        Matcher m=CAUSED_BY.matcher(t);
        String last=null;
        while(m.find())last=m.group(1).trim();
        if(last!=null)return last;
        Matcher e=EXCEPTION.matcher(t);
        String lastE=null;
        while(e.find())lastE=e.group(1).trim();
        return lastE;
    }

    private String lastException(String t){
        String[] lines=t.split("\\R");
        for(int i=lines.length-1;i>=0;i--){
            String line=lines[i].trim();
            if(line.length()<8 || line.length()>700)continue;
            if(line.matches(".*(?i)(Exception|Error|Failure|Fatal|SIGSEGV|SIGABRT).*"))
                return line;
        }
        return null;
    }

    private String detectLoader(String l){
        if(l.contains("net.fabricmc")||l.contains("fabric loader"))return "Fabric";
        if(l.contains("net.minecraftforge")||l.contains("modlauncher")||l.contains("fml loading"))return "Forge";
        if(l.contains("neoforge")||l.contains("net.neoforged"))return "NeoForge";
        if(l.contains("quilt"))return "Quilt";
        if(l.contains("optifine"))return "OptiFine/Vanilla";
        return "Vanilla/indeterminado";
    }

    private String detectStage(String l){
        if(l.contains("mixin")||l.contains("modloading")||l.contains("modresolution")||l.contains("fabricloader")||l.contains("modlauncher"))
            return "Carregamento de mods";
        if(l.contains("opengl")||l.contains("egl_")||l.contains("glfw")||l.contains("vulkan")||l.contains("zink")||l.contains("shader"))
            return "Inicialização gráfica";
        if(l.contains("auth")||l.contains("access token")||l.contains("invalid session"))
            return "Autenticação";
        if(l.contains("download")||l.contains("unknownhost")||l.contains("timeout")||l.contains("http 4"))
            return "Download/Rede";
        if(l.contains("outofmemory")||l.contains("heap"))
            return "Memória/JVM";
        if(l.contains("server thread"))return "Execução do mundo/servidor";
        return "Inicialização/Execução";
    }

    private RuntimeInfo getRuntimeInfo(){
        RuntimeInfo r=new RuntimeInfo();
        if(getContext()!=null){
            android.app.ActivityManager am=(android.app.ActivityManager)getContext().getSystemService(Context.ACTIVITY_SERVICE);
            if(am!=null){
                android.app.ActivityManager.MemoryInfo i=new android.app.ActivityManager.MemoryInfo();
                am.getMemoryInfo(i);
                r.availableMb=i.availMem/(1024L*1024L);
                r.totalMb=i.totalMem/(1024L*1024L);
            }
        }
        r.allocatedMb=LauncherPreferences.DEFAULT_PREF.getInt("allocation",0);
        return r;
    }

    private StorageInfo getStorageInfo(File dir){
        StorageInfo s=new StorageInfo();
        try{
            android.os.StatFs fs=new android.os.StatFs(dir.getAbsolutePath());
            s.freeMb=(fs.getAvailableBytes()/(1024L*1024L));
        }catch(Exception ignored){}
        File mods=new File(dir,"mods");
        File[] list=mods.listFiles();
        s.modCount=list==null?0:list.length;
        return s;
    }

    private List<File> findCandidateFiles(File dir){
        List<File> out=new ArrayList<>();
        addIfFile(out,new File(dir,"latestlog.txt"));
        addIfFile(out,new File(dir,"logs/latest.log"));
        addIfFile(out,new File(dir,"debug.log"));
        addByPattern(out,dir,"hs_err_pid",new String[]{".log",".txt"});
        addByPattern(out,dir,"java_error_in",new String[]{".log",".txt"});
        collectFiles(new File(dir,"crash-reports"),out,3);
        collectFiles(new File(dir,"logs"),out,2);
        File parent=dir.getParentFile();
        if(parent!=null){
            addByPattern(out,parent,"hs_err_pid",new String[]{".log"});
            addByPattern(out,parent,"java_error_in",new String[]{".log"});
        }
        Collections.sort(out,(a,b)->Long.compare(b.lastModified(),a.lastModified()));
        LinkedHashSet<String> seen=new LinkedHashSet<>();
        List<File> unique=new ArrayList<>();
        for(File f:out)if(seen.add(f.getAbsolutePath()))unique.add(f);
        return unique;
    }

    private void addIfFile(List<File> l,File f){if(f.exists()&&f.isFile())l.add(f);}
    private void addByPattern(List<File> l,File dir,String prefix,String[] suffixes){
        File[] files=dir==null?null:dir.listFiles();
        if(files==null)return;
        for(File f:files){
            if(!f.isFile())continue;
            String n=f.getName().toLowerCase(Locale.ROOT);
            if(!n.startsWith(prefix.toLowerCase(Locale.ROOT)))continue;
            for(String s:suffixes)if(n.endsWith(s)){l.add(f);break;}
        }
    }

    private void collectFiles(File dir,List<File> out,int depth){
        if(dir==null||!dir.exists()||depth<0)return;
        File[] files=dir.listFiles();
        if(files==null)return;
        for(File f:files){
            if(f.isDirectory())collectFiles(f,out,depth-1);
            else{
                String n=f.getName().toLowerCase(Locale.ROOT);
                if(n.endsWith(".log")||n.endsWith(".txt"))out.add(f);
            }
        }
    }

    private String readTail(File f,int maxChars)throws Exception{
        long skip=Math.max(0,f.length()-maxChars);
        try(FileInputStream in=new FileInputStream(f)){
            long remain=skip;
            while(remain>0){
                long n=in.skip(remain);
                if(n<=0)break;
                remain-=n;
            }
            BufferedReader br=new BufferedReader(new InputStreamReader(in,StandardCharsets.UTF_8));
            StringBuilder b=new StringBuilder();
            char[] c=new char[8192];
            int n;
            while((n=br.read(c))!=-1)b.append(c,0,n);
            return b.toString();
        }
    }

    private String firstMatch(Pattern p,String t){
        try{
            Matcher m=p.matcher(t);
            return m.find()?m.group(1):null;
        }catch(Exception e){return null;}
    }

    private void copyReport(){
        if(currentReport==null||currentReport.isEmpty())return;
        ClipboardManager cm=(ClipboardManager)requireContext().getSystemService(Context.CLIPBOARD_SERVICE);
        if(cm!=null)cm.setPrimaryClip(ClipData.newPlainText("Mikael Crash Report",currentReport));
        status.setText("Relatório copiado.");
    }

    private void shareReport(){
        if(currentReport==null||currentReport.isEmpty())return;
        Intent i=new Intent(Intent.ACTION_SEND);
        i.setType("text/plain");
        i.putExtra(Intent.EXTRA_SUBJECT,"Mikael Crash Checker");
        i.putExtra(Intent.EXTRA_TEXT,currentReport);
        startActivity(Intent.createChooser(i,"Compartilhar diagnóstico"));
    }

    private File getCurrentProfileDirectory(){
        String cur=LauncherPreferences.DEFAULT_PREF.getString(LauncherPreferences.PREF_KEY_CURRENT_PROFILE,null);
        if(cur==null||cur.trim().isEmpty())return new File(Tools.DIR_GAME_NEW);
        try{
            LauncherProfiles.load();
            MinecraftProfile p=LauncherProfiles.mainProfileJson.profiles.get(cur);
            return p==null?new File(Tools.DIR_GAME_NEW):Tools.getGameDirPath(p);
        }catch(Exception e){return new File(Tools.DIR_GAME_NEW);}
    }

    private static final class RuntimeInfo{
        long availableMb,totalMb,allocatedMb;
    }
    private static final class StorageInfo{
        long freeMb;
        int modCount;
    }
}
