
class TextPair {
  String ch;
  String en;
  TextPair(ch, en) {
    this.ch = ch;
    this.en = en;
  }

  String Get()  {
    return TextK.isCn()? ch : en;
  }
}

class TextK {
  
  bool _isCn = false;

  Map<String,TextPair> texts = new Map();
  TextK() {
    add("暗夜模式", "DarkMode");
    add("刷新编辑器", "Reload Editor");
    add("重设工作区", "Reset WorkSpace");
    add("输入需要过滤的标签", "Enter tag...");
    add("增加一个rss", "Add a rss");
    add("rss 地址", "RSS url");
    add("输入一个rss地址", "Input a rss url");
    add("添加到列表", "Add to List");
    add("文本", "Text");
    add("添加一个文本", "Add a text");
    add("删除该项", "Delete this item");
    add("删除", "Delete");
    add("取消", "Cancel");
    add("选择目录", "Select Directory");
    add("退出", "Quit");
    add("是否重新选择文件目录", "Whether to reselect the file directory");
    add("切换语言", "Switch Language");
    add("没有找到文件保存目录，是否选择文件夹", "The file save directory is not found, whether to select a folder");
  }

  add(String ch, String en) {
    var p = TextPair(ch, en);
    texts[en] = p;
    texts[ch] = p;
  }

  static TextK _ins = null;

  static bool isCn() {
    return instance()._isCn;
  } 

  static toggle() {
    instance()._isCn = !instance()._isCn;
  }

  static TextK instance() {
    if (_ins == null) {
      _ins = new TextK();
    }
    return _ins;
  }

  static Get(String key) {
    key = key.trim();
    var p =  instance().texts[key];
    if (p == null) {
      print("ERRRO: TextK has not this value ${key}");
      return key;
    } else {

     return p.Get();
    }
  }
}