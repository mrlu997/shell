# MT3000刷机Clash核心

## 通过iStoreOS安装Openclash后，在*插件设置——版本更新*处会显示Clash内核丢失

![images](https://github.com/mrlu997/shell/blob/main/core/images/01.png){:height="50%" width="50%"}


## 此时，路由器尚不能访问外网，因此无法自动更新下载Clash内核，且Github上的Clash内核仓库已经跑路
## 因此，可以使用本地收到上传的方式更新内核：

## 1、通过ssh连接路由器，并将3个clash内核复制到指定位置（如图）

![images](https://github.com/mrlu997/shell/blob/main/core/images/02.png)

## 2、给内核文件赋予可执行权限，' chmod 777 x '

![images](https://github.com/mrlu997/shell/blob/main/core/images/03.png)

## 3、刷新路由器即可。建议重启一下路由器

![images](https://github.com/mrlu997/shell/blob/main/core/images/04.png)
