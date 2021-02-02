# bloc-cubit-hanson
他の言語でも役に立ちそうなので、Dartの状態管理ライブラリである`Bloc`の概念を学んでみる。  
本来はFlutterでの利用になると思うが、いったん素のDart環境で使ってみる。  

https://bloclibrary.dev/#/coreconcepts?id=cubit

Flutterについては少し触れたのみだが、以下の特徴がある。

- `StatelessWidget`と`StatefulWidget`がある。
- `StatelessWidget`は状態を持たない。
- `StatefulWidget`は状態を持つ。状態は`setState()`で変更できる。

`StatefulWidget`の`setState()`でそのWidgetがもつ状態を変更できるものの、増えてくると管理が大変になる。  
ここでの問題は、UIのためのWidgetと状態が同じコンポーネントのなかにあること。  
Blocを使う事でそれらを分離し、別々に管理することで複雑が避けられるというもの。  
※実際にサンプルアプリを動かしたところ、`StatelessWidget`だけで、従来の`StatefulWidget`と同様の振る舞いが実現できた。  

## Cubitとは
CubitはBlocライブラリに含まれている。  
よりシンプルな形でBlocライブラリの恩恵が受けられるように設計されている模様。  
※この時点ではBlocはこれから試すので、その違いはまだ分かっていない。しかしSimpleであるという特徴があるとの述ドキュメントにある。  

まずは以下の概念図を参照。  

https://bloclibrary.dev/#/coreconcepts

このようにCubitは以下の特徴がある。  
- UIに対して状態変更をトリガーする関数を公開する。
- UIはCubitが公開した関数を呼び出す。(状態変更をトリガーするため)
- Cubitは状態を`state`として公開し、UIがこれを参照できるようにする。


### Cubitクラスの実装

実際に書いてみる。  
実際のソースコードは[counter_cubit.dart](./counter_cubit.dart)にある。  
今回は単にカウンタ値を管理するCubitを作成する。  

```dart
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
}
```

`CounterCubit`クラスは`Cubit<T>`を継承している。  
この`Cubit`クラスはBlocライブラリから提供されているもの。  
管理する状態に応じてDartのGenericsを使って型を指定できる。  
今回はカウンタ値のみの管理で、これは`int`型なので`Cubit<int>`のように記述している。  
しかし、これはプリミティブ型でなくともクラスで指定してもよい。  

また、コンストラクタを実装する必要がある。  

```dart
  CounterCubit() : super(0);
```

このように、今回は単に親クラスに初期値`0`を送って初期化するというもの。  
親クラスのコンストラクタを必ず呼び出す必要があることと、Cubitクラスのジェネリクスでしていした型を渡してやる。  

次に、状態を変更するメソッドをみてみる。  


```dart
  void increment() => emit(state + 1);
```

以下のポイントを確認。  

- 現在の状態には`state` getter経由でアクセスする。  
- 状態の変更は`emit()`メソッドを呼び出す。（これがFlutterではWidgetを再描画する契機になる。）

※`emit()`はprotectedなメソッドなので、Cubeの子クラス以外からは呼べないので安心。  

### onChange
そのCubitのなで、状態の更新を契機にして何か処理をしたい場合は、`onChange`メソッドをオーバーライドする。  

```dart
  @override
  void onChange(Change<int> change) {
    print(change);
    super.onChange(change);
  }
```

以下のような出力がえられる。  

```
Change { currentState: 0, nextState: 1 }
Change { currentState: 1, nextState: 2 }
```
`onChange`は実際に状態が変更される直前に実行される。  
そのため、`currentState`が現在の状態、`nextState`がこれから変更される状態になる。  

### グローバルなonChange
大きいアプリでは、複数のCubitが定義されていが普通。  
そして、そのアプリ内の全てのCubitについて、状態が変わったら特定の処理を行いたい場合は、グローバルな`onChange`が利用できる。  

まずは、以下のように`BlocObserver`を継承したクラスを作成する。  

```dart
import 'package:bloc/bloc.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(Cubit cubit, Change change) {
    print('${cubit.runtimeType} $change');
    super.onChange(cubit, change);
  }
}
```

そして、`main`関数無いで、`Bloc.observer`に設定する。  

```dart
  Bloc.observer = SimpleBlocObserver();
```

実行すると、以下が得られる。  

```
Change { currentState: 0, nextState: 1 }
CounterCubit Change { currentState: 0, nextState: 1 }
Change { currentState: 1, nextState: 2 }
CounterCubit Change { currentState: 1, nextState: 2 }
```

※Bloc.observerのonChangeはCubitのonChangeの後に呼び出される。
