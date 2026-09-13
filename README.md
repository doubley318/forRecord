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
DOMAIN=你的域名 sudo -E bash deploy.sh
```

脚本会安装 `git` 和 `nginx`，把项目部署到 `/var/www/forRecord`，并生成 Nginx 配置。
