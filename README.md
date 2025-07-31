GUIポチポチで量子回路学習を体験できるデモ

# Installation
Juliaのインストールは[https://julialang.org/install/](https://julialang.org/install/)を参照。

インストール後、juliaのREPLで
```julia
pkg> add https://github.com/satoru0510/OpenCampus2025
```
または
```julia
julia> import Pkg
julia> Pkg.add(url="https://github.com/satoru0510/OpenCampus2025")
```

# Usage
```julia
julia> using OpenCampus2025 #必要なパッケージが自動でインストールされます。初回は少し時間がかかります。
julia> OpenCampus2025.init() #学習に使うデータを準備します。初回は少し時間がかかります。何か聞かれたら"y"と入力してEnter。
julia> run_demo() #ウィンドウが立ち上がります。
```

# もう少し詳しい説明
[https://satoru0510.github.io/oc2025.html](https://satoru0510.github.io/oc2025.html)
