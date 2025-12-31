# Learn CI/CD

这是一个学习 CI/CD（持续集成/持续交付）的示例项目。

## 什么是 CI/CD？

CI/CD 是现代软件开发中的核心实践，指的是**持续集成**（Continuous Integration）和**持续交付/部署**（Continuous Delivery/Deployment）。

### 持续集成（CI）

开发者频繁地将代码变更合并到主分支（通常每天多次）。每次提交代码后，自动化系统会：

- 构建应用程序
- 运行自动化测试
- 检查代码质量

这样可以快速发现集成问题和 bug，避免"集成地狱"——即多个开发者长时间独立工作后合并代码时出现大量冲突。

### 持续交付（CD）

在 CI 的基础上，确保代码始终处于可发布状态。通过自动化流程，代码经过测试后可以随时部署到生产环境，但实际部署需要手动批准。

### 持续部署（CD）

更进一步，通过所有测试的代码变更会自动部署到生产环境，无需人工干预。

### 主要好处

- **更快的反馈**：几分钟内就能知道代码是否有问题
- **降低风险**：小批量、频繁的发布比大规模发布风险更低
- **提高效率**：自动化减少手动工作
- **更快交付价值**：新功能和修复能更快到达用户手中

常见的 CI/CD 工具包括 Jenkins、GitLab CI/CD、GitHub Actions、CircleCI 等。

---

## 项目结构

```
Learn_CICD/
├── .github/
│   └── workflows/
│       └── test.yml          # GitHub Actions 工作流配置
├── src/
│   └── learn_cicd/
│       ├── __init__.py
│       └── main.py           # 主程序
├── tests/
│   ├── __init__.py
│   └── test_main.py          # 测试文件
├── pyproject.toml            # 项目配置
├── uv.lock                   # 依赖锁定文件
├── README.md
└── LICENSE
```

---

## GitHub Actions 工作流语法示例

### 基础工作流

```yaml
name: Test

on:
  push:
    branches: 
      - main
  pull_request:
    branches:
      - main

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      
      - name: Install dependencies
        run: |
          pip install pytest
          pip install -e .
      
      - name: Run tests
        run: pytest tests/
```

### 使用 UV 的工作流

```yaml
name: Test with UV

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    container: astral/uv:python3.12-bookworm-slim
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Install dependencies
        run: uv sync
      
      - name: Run tests
        run: uv run pytest tests/
```

### 多平台测试

```yaml
name: Multi-platform Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        python-version: ['3.10', '3.11', '3.12']
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python ${{ matrix.python-version }}
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
      
      - name: Install dependencies
        run: |
          pip install pytest
          pip install -e .
      
      - name: Run tests
        run: pytest tests/
```

### 带代码覆盖率的工作流

```yaml
name: Test with Coverage

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      
      - name: Install dependencies
        run: |
          pip install pytest pytest-cov
          pip install -e .
      
      - name: Run tests with coverage
        run: pytest --cov=src tests/
      
      - name: Upload coverage reports
        uses: codecov/codecov-action@v4
```

### 带 Linting 和格式检查的完整流程

```yaml
name: CI Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      
      - name: Install linting tools
        run: |
          pip install ruff black mypy
      
      - name: Run ruff
        run: ruff check src/ tests/
      
      - name: Check formatting
        run: black --check src/ tests/
      
      - name: Type checking
        run: mypy src/

  test:
    needs: lint
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      
      - name: Install dependencies
        run: |
          pip install pytest
          pip install -e .
      
      - name: Run tests
        run: pytest tests/
```

---

## GitHub Actions 常用语法说明

### 触发器（on）

```yaml
# 单个事件
on: push

# 多个事件
on: [push, pull_request]

# 指定分支
on:
  push:
    branches:
      - main
      - develop
  pull_request:
    branches:
      - main

# 指定路径
on:
  push:
    paths:
      - 'src/**'
      - 'tests/**'

# 定时触发（cron）
on:
  schedule:
    - cron: '0 0 * * *'  # 每天午夜运行
```

### 作业（jobs）

```yaml
jobs:
  job1:
    runs-on: ubuntu-latest
    steps:
      - run: echo "First job"
  
  job2:
    needs: job1  # 依赖 job1 完成后才运行
    runs-on: ubuntu-latest
    steps:
      - run: echo "Second job"
```

### 矩阵策略（matrix）

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest]
    python-version: ['3.10', '3.11', '3.12']
    # 会生成 2 × 3 = 6 个作业组合
```

### 环境变量

```yaml
env:
  GLOBAL_VAR: "global value"

jobs:
  test:
    env:
      JOB_VAR: "job value"
    steps:
      - name: Use variables
        env:
          STEP_VAR: "step value"
        run: |
          echo $GLOBAL_VAR
          echo $JOB_VAR
          echo $STEP_VAR
```

### 条件执行

```yaml
steps:
  - name: Only on main branch
    if: github.ref == 'refs/heads/main'
    run: echo "Main branch"
  
  - name: Only on success
    if: success()
    run: echo "Previous steps succeeded"
  
  - name: Only on failure
    if: failure()
    run: echo "Something failed"
```

---

## 本地开发

### 安装依赖

```bash
# 使用 uv
uv sync

# 或使用 pip
pip install -e .
pip install pytest
```

### 运行测试

```bash
# 使用 uv
uv run pytest tests/

# 或直接使用 pytest
pytest tests/
```

### 运行主程序

```bash
# 使用 uv
uv run python src/learn_cicd/main.py

# 或直接运行
python src/learn_cicd/main.py
```

---

## 学习资源

- [GitHub Actions 官方文档](https://docs.github.com/en/actions)
- [GitHub Actions 工作流语法](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [awesome-actions](https://github.com/sdras/awesome-actions) - GitHub Actions 资源集合

## License

MIT License