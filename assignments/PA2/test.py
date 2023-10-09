import subprocess
import os

def run(filename):
    command1 = "./lexer examples/{} > file1.txt".format(filename)  # 用你的第一个命令替换
    command2 = "lexer examples/{} > file2.txt".format(filename)  # 用你的第二个命令替换

    subprocess.check_output(command1, shell=True, text=True)
    subprocess.check_output(command2, shell=True, text=True)

def compare_files(file1_path, file2_path, output_path):
    with open(file1_path, 'r') as file1, open(file2_path, 'r') as file2:
        lines1 = file1.readlines()
        lines2 = file2.readlines()

    # 比较两个文件的每一行
    diff_lines = []
    for i, (line1, line2) in enumerate(zip(lines1, lines2), start=1):
        if line1 != line2:
            diff_lines.append(f"Line {i}: {line1.strip()} != {line2.strip()}")
            print(line1)

    # 将不同的行数输出到文件
    with open(output_path, 'a') as output_file:
        output_file.write("\n".join(diff_lines))

def get_all_files_in_folder(folder_path):
    # 获取文件夹下所有文件的文件名
    files = []
    for file_name in os.listdir(folder_path):

        # 使用绝对路径，以确保得到完整的文件路径
        file_path = os.path.join(folder_path, file_name)
        if os.path.isfile(file_path):
            files.append(file_name)
    return files



if __name__ == "__main__":
    # 使用subprocess执行命令并捕获输出


    file1_path = "file1.txt"  # 替换为第一个文件的路径
    file2_path = "file2.txt"  # 替换为第二个文件的路径
    output_path = "differences.txt"
    folder_path = "examples"  # 替换为你的文件夹路径
    file_names = get_all_files_in_folder(folder_path)

    # 打印文件名数组
    for file_name in file_names:
        print(file_name)
        run(file_name)
        compare_files(file1_path, file2_path, output_path)
    print(f"Differences written to {output_path}")