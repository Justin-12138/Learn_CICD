from main import main


def test_main_exists():
    """测试main函数是否存在且可调用"""
    assert callable(main)
    main()  # 确保能运行不报错