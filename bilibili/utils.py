# coding=utf-8
import json
import os
import shutil


def video_rename(dir):
    # E:\OneDrive\个人资料\英语\词汇\55852277
    path = os.path.realpath(dir)
    print(path)

    list = os.listdir(path)
    print(os.path.abspath(path))
    print(os.path.basename(path))

    # 55852277
    bili_series_num = os.path.basename(path)
    # 55852277.dvi
    series_meta_file = bili_series_num + ".dvi"
    # E:\OneDrive\个人资料\英语\词汇\55852277\55852277.dvi
    series_meta_file = os.path.join(path, series_meta_file)
    # 【2019版】托福全程直达110分班（口语 + 听力 + 阅读 + 写作 + 词汇）
    series_title = get_json_key_value(series_meta_file, 'Title')
    series_combine_dir = os.path.join(path, series_title)
    os.mkdir(series_combine_dir)

    for file in list:
        # 分p文件夹
        part_dir = os.path.join(path, file)
        # 判断是文件夹
        if os.path.isdir(part_dir):
            dir_files = os.listdir(part_dir)
            for dir_file in dir_files:
                if dir_file.endswith('mp4'):
                    # 分p的视频信息文件
                    part_meta_file = os.path.join(part_dir, bili_series_num) + '.info'
                    part_name = get_json_key_value(part_meta_file, 'PartName')
                    mp4_file_path = os.path.join(part_dir, dir_file)
                    print(part_name)
                    print(mp4_file_path)
                    target_mp4_file_path = os.path.join(part_dir, part_name + ".mp4")
                    print(target_mp4_file_path)
                    os.rename(mp4_file_path, target_mp4_file_path)
                    shutil.move(target_mp4_file_path, series_combine_dir)


def get_json_key_value(json_file, key_name):
    with open(json_file, 'r', encoding='utf8') as f:
        text = json.load(f)
        return text[key_name]