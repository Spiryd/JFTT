import platform
import os
import filecmp
import subprocess

os_type = platform.system()
comp_dir = "expectations/"
output_dir = "output/"
input_dir = "tests/"

names = ["test0"]

os.system("make")
for name in names:

    if os_type == "Windows":
        command = f'powershell.exe cat {input_dir}{name}.xml | a.exe > {output_dir}{name}.xml'
        subprocess.call(command, shell=True)
        #os.system(command)
    else:
        os.system(f'cat {input_dir}{name}.xml | ./a.out > {output_dir}{name}.xml')

    r = filecmp.cmp(f"{output_dir}{name}.xml", f"{comp_dir}{name}_exp.xml", shallow=False)
    print(r)
