<#
背景：通过Windows应用商店的Windows App 哔哩哔哩可以直接下载B站的视频
         不过是以视频AID命令的文件夹中，视频名称也不是正式的视频名称。

实现思路：
  1. 获取目的目录根目录下的子目录对象，和文件对象。
  2. 从文件对象中读取dvi文件得到视频课程的名称
  3. 循环遍历子目录
    1). 读取子目录中的info文件并取出“PartName”字段
    2). 以1).中读取的“PartName”字段，重命名MP4格式的文件
      
#>

$scripts_dir = Split-Path -Parent $MyInvocation.MyCommand.Definition # 脚本所在路径
# $root_path = $args  	# $args用于命令行传参数
$root_path = "F:\Bilibili_Cache\200857352\"

write-host "------------------------------------------------------"
write-host "进入根目录：" $root_path.FullName
write-host "------------------------------------------------------"
Set-Location $root_path # 切换到传入参数的需要操作目录
write-host "获取课程文件夹信息"
write-host "------------------------------------------------------"
$split_dir = Get-ChildItem -Path $root_path -Directory  # 获取根目录下的子文件夹对象

$dvi_name = (Get-ChildItem -Path $root_path -File | Where-Object -FilterScript {$_.Name -like "*.dvi"} ).Name # 获取根目录下的“.dvi”文件名称

$serial_video_name = (Get-Content $root_path$dvi_name -Encoding utf8 | ConvertFrom-Json).Title  # 读取根目录下的dvi文件获得视频课程的名称
write-host "获取课程文件夹信息成功"
write-host "------------------------------------------------------"
<#
write-host "子目录对象：" $split_dir
write-host "dvi文件名：" $dvi_name
write-host "视频课程名称：" $serial_video_name
#>

write-host "新建课程文件夹信息"
write-host "------------------------------------------------------"
 
# 以课程名称创建文件夹
# 判断文件夹是否存在，存在删除后新建
$path_isexist = (Test-Path ((Get-Location).Path.ToString() +"\*") -Include $serial_video_name)
 if ( $path_isexist -eq $true ){
      Remove-Item -Path $serial_video_name    # 删除旧的课程目录
      New-Item $serial_video_name -ItemType Directory    # 新建课程目录
 }else{
      New-Item $serial_video_name -ItemType Directory    # 新建课程目录
 }
 
write-host "------------------------------------------------------"
write-host "处理课程目录"
write-host "------------------------------------------------------"

# 循环遍历子目录，将子目录中的.info文件的“PartName”字段取出，作为mp4格式文件的文件名
ForEach ($subdir in $split_dir){
     
     # write-host "当前目录1："  (pwd).Path
     write-host "进入子目录" $subdir.FullName
     Set-Location $subdir   #进入子目录
     # write-host "当前目录2："  (pwd).Path
     $subvideoname = ((Get-Content -Encoding utf8 (Get-ChildItem $subdir.FullName  "*.info" ).FullName ) | ConvertFrom-Json).PartName  # 从info文件中取得子视频的名称
     $subvideoname = ($subvideoname).ToString() + ".mp4"   # 文件名加上后缀
     # write-host "当前目录3："  (pwd).Path
     write-host "当前子目录中的视频名称为：" (Get-ChildItem -Filter  "*.mp4").FullName
     # write-host "当前目录4："  (pwd).Path
     (Get-ChildItem  -Filter "*.mp4") | Rename-Item -NewName $subvideoname   # 子目录的mp4格式文件重命名
     # write-host "当前目录5："  (pwd).Path
     Move-Item (Get-ChildItem -Filter "*.mp4" ).FullName ($subdir.Parent.FullName.ToString() + "\" + $serial_video_name )  # 将mp4文件拷贝到上级目录下实现建立的课程目录中
     # write-host "当前目录6："  (pwd).Path
     Set-Location $subdir.Parent.FullName  # 返回上级目录
}
write-host "处理结束："
write-host "------------------------------------------------------"

Set-Location $scripts_dir # 回到脚本所在路径
