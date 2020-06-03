import os
import shutil

def copiarPastas(src,dest):
    src_files = os.listdir(src)
    for file_name in src_files:
        if os.path.isfile(src  + file_name):
            shutil.copy(src + file_name, dest)

os.system('cd /home/travis/build/ \n  git clone https://neurodeveloperISD:,Lc258147@github.com/C4NESub9/googleData.git')
copiarPastas('/home/travis/build/lordcobisco/covid-br-model-epiforecasts/_nowcasts/covid-regional/brazil/cities/','/home/travis/build/googleData/dataMC/cities/')
copiarPastas('/home/travis/build/lordcobisco/covid-br-model-epiforecasts/_nowcasts/covid-regional/brazil/cities-summary/','/home/travis/build/googleData/dataMC/cities-summary/')
os.system('cd /home/travis/build/googleData/ \n git remote set-url origin https://neurodeveloperISD:,Lc258147@github.com/googleData.git \n git add . \n git commit -m "Atualizacao dos dados de Salvador" \n git push')
