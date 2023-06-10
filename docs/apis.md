
# apis.md

作为 web 模块的一个能力提供

## 1. js call dart 

`` dart

    web.registerFunction("openLink", (dynamic data) {
      var url = data["url"] as String;
      if (url.startsWith("#")) {
        var target = url.substring(1);
        // find
        ListItemData listItemData =
            this.data?.data?.where((element) => element.path == target)?.first;
        if (listItemData != null) {
          this.onPressSingleItemFunc(listItemData);
        }
      } else {
        ChildProcess(ChildProcessArg.from("open ${url}")).run();
      }
    });
```

``` js
 window.denkGetKey("sendIpcMessage")({
    name: "openLink",
    data: {
        url: el.attributes.href.value,
    },
});

```

## 2. dart call js

```

web.executeJs("location.reload(false)");

```


## 2. js call dart with result