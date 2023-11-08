import platform
import os
import filecmp

os_type = platform.system()
comp_dir = "expectations/"
output_dir = "output/"
input_dir = "tests/"

names = ["l2z1a", "l2z1b"]

os.system("make")
for name in names:

    if os_type == "Windows":
        command = f'Get-Content {input_dir}{name}.txt | ./a.exe > {output_dir}{name}.txt'
        os.system(command)
    else:
         os.system(f'cat {input_dir}{name}.txt | ./a.out > {output_dir}{name}.txt')

    r = filecmp.cmp(f"{output_dir}{name}.txt", f"{comp_dir}{name}.r1.txt", shallow=False)
    print(r)
    r = filecmp.cmp(f"{output_dir}{name}.txt", f"{comp_dir}{name}.r2.txt", shallow=False)
    print(r)

