# 画面輝度調整ツール

## はじめに

画面輝度を調整するプログラムです。
tray のメニューから輝度を選択する形です。

## インストール

src/adjbri.rb の先頭の方に、

```rb
BRIGHTNESS_PATH = '/sys/class/backlight/intel_backlight/brightness'
MAX_BRIGHTNESS_PATH = '/sys/class/backlight/intel_backlight/max_brightness'
```

という部分がありますので、環境に合わせて修正して下さい。

その上で、PATH の通った場所にコピーしてください。

## 使い方

```
adjbri.rb <brightness[,...]>
```

といった形で使います。

&lt;brightness[,...]&gt; には使いたい輝度を列挙します。
指定の方法は2種類あります。

- 直接指定

  `/sys/class/backlight/*/brightness` に書き込む値を直接指定します。

- 割合指定

  `/sys/class/backlight/*/max_brightness` を 100% とし、100% に対する割合で指定します。

例えば、

```
adjbri.rb 1,25%,50%
```

と指定します。

実行すると tray に icon が表示され、
この icon を右クリックするとメニューが表示されます。
メニューには指定した輝度が列挙されているので、選択してください。
輝度が変わります。

テストが終わったら、自分の環境に合わせて、
自動起動するようにしておくと良いでしょう。

## 輝度が上がったり下がったりする場合

他に輝度を調整するプログラムが動いているのかもしれません。
特に、GNOME や KDE などの設定を確認してください。

## ライセンス

GPL3。

## 作者

原野裕樹 &lt;masm@masm11.ddo.jp&gt;
