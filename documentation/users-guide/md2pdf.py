import os
import subprocess
import markdown

def md_to_pdf(md_file_path: str, pdf_file_path: str = None):
    """单个 MD 转 PDF"""
    if not os.path.exists(md_file_path):
        print(f"❌ 文件不存在：{md_file_path}")
        return

    # 默认输出同名 PDF
    if pdf_file_path is None:
        base, _ = os.path.splitext(md_file_path)
        pdf_file_path = base + ".pdf"

    try:
        # 读取 Markdown
        with open(md_file_path, "r", encoding="utf-8") as f:
            md_content = f.read()

        # 转 HTML（支持表格、代码块）
        html_content = markdown.markdown(
            md_content,
            extensions=[
                "tables",
                "fenced_code",
                "toc",
            ]
        )

        # 带样式的完整 HTML
        html = f"""
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <style>
        body {{ font-family: Microsoft YaHei, sans-serif; margin: 40px; line-height: 1.8; }}
        h1, h2, h3, h4 {{ color: #2c3e50; }}
        pre {{ background: #f5f5f5; padding: 15px; border-radius: 5px; }}
        code {{ background: #f0f0f0; padding: 2px 4px; border-radius: 3px; }}
        table {{ border-collapse: collapse; width: 100%; margin: 15px 0; }}
        th, td {{ border: 1px solid #ccc; padding: 8px 12px; }}
    </style>
</head>
<body>
{html_content}
</body>
</html>
        """

        temp_html = "~temp_convert.html"
        with open(temp_html, "w", encoding="utf-8") as f:
            f.write(html)

        # 转换 PDF
        subprocess.run(
            ["wkhtmltopdf", "--encoding", "utf-8", temp_html, pdf_file_path],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        print(f"✅ 转换成功：{pdf_file_path}")

    except subprocess.CalledProcessError as e:
        print(f"❌ 转换失败：{md_file_path}，错误：{e.stderr}")
    finally:
        if os.path.exists("~temp_convert.html"):
            os.remove("~temp_convert.html")

def batch_convert_md_to_pdf():
    """批量转换当前文件夹下所有 .md 文件"""
    print("🔍 正在扫描当前目录所有 .md 文件...\n")

    # 获取当前目录所有文件
    current_dir = os.getcwd()
    files = os.listdir(current_dir)

    # 筛选出所有 .md 文件
    md_files = [f for f in files if f.lower().endswith(".md")]

    if not md_files:
        print("⚠️ 当前目录没有找到任何 .md 文件")
        return

    print(f"📄 找到 {len(md_files)} 个 Markdown 文件")
    print("-" * 50)

    # 逐个转换
    for filename in md_files:
        md_path = os.path.join(current_dir, filename)
        md_to_pdf(md_path)

    print("-" * 50)
    print("🎉 全部转换完成！")

if __name__ == "__main__":
    batch_convert_md_to_pdf()
