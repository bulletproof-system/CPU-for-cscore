'''
Author: ltt
Date: 2022-12-12 15:13:29
LastEditors: ltt
LastEditTime: 2022-12-12 15:21:34
FilePath: dump.py
'''

import subprocess


def run(command, desc=None, errdesc=None):
    """调用命令"""
    if desc is not None:
        print(desc)

    result = subprocess.run(
        ' '.join(command), stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)

    if result.returncode != 0:
        message = f"""{errdesc or 'Error running command'}.
Command: {' '.join(command)}
Error code: {result.returncode}
stdout: {result.stdout.decode(encoding="gb2312", errors="ignore") if len(
    result.stdout)>0 else '<empty>'}
stderr: {result.stderr.decode(encoding="gb2312", errors="ignore") if len(
    result.stderr)>0 else '<empty>'}
"""
        raise RuntimeError(message)
    return result.stdout.decode(encoding="utf8", errors="ignore")


def main():
	asm = "P8.asm"
	mars = "Mars_P7.jar"
	text_path = "text.txt"
	ktext_path = "ktext.txt"
	code_path = "code.txt"
	coe_path = "init.coe"
	run(["java", "-jar", mars, "ae1", "db", "a", "me", "nc", "mc",
	    "CompactDataAtZero", "dump", ".text", "HexText", text_path, asm])
	run(["java", "-jar", mars,"ae1","db", "a","me", "nc", "mc", "CompactDataAtZero", "dump", "0x4180-0x6ffc", "HexText", ktext_path, asm])
	with open(text_path, "r") as text_file:
		text = text_file.readlines()
	with open(ktext_path, "r") as ktext_file:
		ktext = ktext_file.readlines()
	codes = ["00000000\n" for _ in range(4096)]
	coes =  ["00000000,\n" for _ in range(4096)]
	for (i, text_code) in zip(range(len(text)), text):
		codes[i] = text_code
		coes[i] = text_code[:-1] + ",\n"
	for (i, ktext_code) in zip(range((0x4180-0x3000)//4, (0x4180-0x3000)//4+len(ktext)), ktext):
		codes[i] = ktext_code
		coes[i] = ktext_code[:-1] + ",\n"
	with open(code_path, "w") as code_file:
		code_file.write(''.join(codes))
	coes = ["memory_initialization_radix=16;\n","memory_initialization_vector=\n"]+coes[:-1]+[coes[-1][:-2]+";\n"]
	with open(coe_path, "w") as coe_file:
		coe_file.write(''.join(coes))

if __name__ == "__main__":
	main()