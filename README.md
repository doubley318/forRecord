# 网页版计算器

一个可直接静态部署的网页版计算器，支持鼠标点击和键盘输入。

## 本地预览

直接用浏览器打开 `index.html` 即可。

也可以用任意静态服务器预览，例如：

```bash
python3 -m http.server 8080
```

然后访问：

```text
http://localhost:8080
```

## 上传到 GitHub

```bash
git init
git add .
git commit -m "Add web calculator"
git branch -M main
git remote add origin https://github.com/doubley318/forRecord.git
git push -u origin main
```

## 服务器一键部署

在服务器上执行：

```bash
git clone https://github.com/doubley318/forRecord.git
cd forRecord
sudo bash deploy.sh
```

如果已经绑定域名：

```bash
sudo bash deploy.sh 你的域名
```

例如：

```bash
sudo bash deploy.sh www.zxlmoney.online
```

脚本会安装 `git` 和 `nginx`，把项目部署到 `/var/www/forRecord`，并生成 Nginx 配置。

当域名已存在 Let’s Encrypt 证书时，脚本会自动启用 HTTPS，并保留
`/moneybook/api/v1/` 到 `http://127.0.0.1:2523` 的反向代理。因此网页部署不会
影响同域名下的小程序后端接口。证书尚未申请时，脚本只配置 HTTP；申请证书后再次
执行同一部署命令即可启用 HTTPS。

默认后端地址为 `http://127.0.0.1:2523`；如服务监听地址不同，可以在执行时覆盖：

```bash
sudo BACKEND_UPSTREAM=http://127.0.0.1:2523 bash deploy.sh www.zxlmoney.online
```
