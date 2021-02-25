# burger_war_kit 保守用手順書
burger_war_kitリポジトリでは、[burger_war_dev](https://github.com/p-robotics-hub/burger_war_dev)に最低限必要なツールやライブラリをインストールしたDockerイメージ(burger-war-kitイメージ)を提供します。

本ドキュメントには、burger-war-kitイメージを開発するための情報を記載しています。

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Dockerイメージの構成](#docker%E3%82%A4%E3%83%A1%E3%83%BC%E3%82%B8%E3%81%AE%E6%A7%8B%E6%88%90)
- [Docker関連のファイル構成](#docker%E9%96%A2%E9%80%A3%E3%81%AE%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E6%A7%8B%E6%88%90)
- [開発の流れ](#%E9%96%8B%E7%99%BA%E3%81%AE%E6%B5%81%E3%82%8C)
- [事前準備](#%E4%BA%8B%E5%89%8D%E6%BA%96%E5%82%99)
  - [Personal access token の作成](#personal-access-token-%E3%81%AE%E4%BD%9C%E6%88%90)
- [コマンド](#%E3%82%B3%E3%83%9E%E3%83%B3%E3%83%89)
  - [burger-war-kitイメージのビルド](#burger-war-kit%E3%82%A4%E3%83%A1%E3%83%BC%E3%82%B8%E3%81%AE%E3%83%93%E3%83%AB%E3%83%89)
  - [burger-war-kitイメージからコンテナを起動](#burger-war-kit%E3%82%A4%E3%83%A1%E3%83%BC%E3%82%B8%E3%81%8B%E3%82%89%E3%82%B3%E3%83%B3%E3%83%86%E3%83%8A%E3%82%92%E8%B5%B7%E5%8B%95)
  - [ghcr.ioへのログイン](#ghcrio%E3%81%B8%E3%81%AE%E3%83%AD%E3%82%B0%E3%82%A4%E3%83%B3)
  - [burger-war-kitイメージをghcr.ioへプッシュ](#burger-war-kit%E3%82%A4%E3%83%A1%E3%83%BC%E3%82%B8%E3%82%92ghcrio%E3%81%B8%E3%83%97%E3%83%83%E3%82%B7%E3%83%A5)
- [スクリプト設定ファイル](#%E3%82%B9%E3%82%AF%E3%83%AA%E3%83%97%E3%83%88%E8%A8%AD%E5%AE%9A%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB)
- [補足](#%E8%A3%9C%E8%B6%B3)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

<br />

## Dockerfileの構成
本リポジトリと[burger_war_dev](https://github.com/p-robotics-hub/burger_war_dev)のDockerfileを合わせた継承関係は以下となります。  

![Dockerfile構成](https://user-images.githubusercontent.com/76457573/109110935-668afe80-777b-11eb-9e10-9ea9a1a459e2.png)

本リポジトリで扱うのは、図中の「burger_war_kit」です。  
他のイメージについては、burger_war_devリポジトリに含まれています。

<br />

## Docker関連のファイル構成
burger-war-kitイメージの作成に関連するファイルは以下となります。

```
burger_war_kit
|-- .github/workflows
|   |-- image-release.yml         ... burger-war-kitイメージに正式バージョンを付与するworkflowファイル
|   |-- image-test.yml            ... burger-war-kitイメージを自動ビルド＆テストするworkflowファイル
|   |-- update_toc.yml            ... ドキュメントの目次を作成・更新するworkflowファイル
|-- commands
|   |-- config.sh                 ... 各スクリプトで参照する共通設定ファイル
|   |-- docker-build.sh           ... Dockerイメージをビルドするためのスクリプト
|   |-- docker-launch.sh          ... Dockerイメージからコンテナを起動するためのスクリプト
|   |-- docker-login.sh           ... ghcr.ioにログインするためのスクリプト
|   |-- docker-push.sh            ... pushするためのスクリプト
|   |-- kit.sh                    ... burger-war-kitコンテナ上でコマンドを実行するためのスクリプト
|-- doc
|   |-- FOR_MAINTAINER.md         ... 本ドキュメント
|-- docker
|   |-- entrypoint.sh             ... DockerのENTRYPOINTで指定する実行スクリプト
|   |-- kit
|   |   |-- Dockerfile            ... burger-war-kitイメージを作成するためのDockerfile
|   |-- templates                 ... docker build時に/home/developer直下にコピーするファイル群
|   |   |-- .gazebo
|   |   |   |-- gui.ini           ... Gazeboのウィンドウ配置設定用(自動テストで使用)
|   |   |-- .ignition/fuel
|   |   |   |-- config.yaml       ... Gazebo起動時に出るエラーを抑制するための設定ファイル
|   |   |-- export_env            ... コンテナ内のユーザーに必要な設定(`.bash_profile`と`.bashrc`に追記する内容)
```

<br />

## 開発の流れ
基本的な開発の流れは以下になります。

1. burger-war-kitイメージに影響があるファイルの修正(Dockerfileなど)
2. burger-war-kitイメージのビルド
3. burger-war-kitイメージの動作確認
   - 問題があれば1に戻る
4. 修正したDockerfileなどをGitHubにプッシュ
5. GitHub Actionsによる自動ビルド＆テスト
   - 問題があれば1に戻る
6. GitHub Actionsでビルドされたburger-war-kitイメージ(テスト版)を使って動作確認
   - 問題があれば1に戻る
7. 開発者はdevブランチにプルリクエスト
   - リポジトリ管理者がdevへマージ時に、自動テスト実施
8. devブランチで動作確認
   - burger-war-devイメージでも動作確認を行う
   - 問題があれば1に戻る
9. リポジトリ管理者がmainにマージ
10. burger-war-kitイメージをリリース(burger-war-kitイメージ(テスト版)にlatestタグを付与)

<br />

以降で具体的な手順について説明します。

特に記載がない場合は、いずれの手順もburger_war_kitのルートディレクトリに移動して実行する想定で記載しています。

```bash 
cd $HOME/catkin_ws/src/burger_war_kit
```

<br />

## 1. bburger-war-kitイメージに影響があるファイルの修正(Dockerfileなど)

<br />

## 2. burger-war-kitイメージのビルド
修正したDockerfileをビルドしてburger-war-kitイメージを作成するには、以下のコマンドを実行して下さい。

```bash
bash commands/docker-build.sh
```

イメージに任意のバージョン(Dockerのタグ)を付与したい場合は、`-v`オプションでバージョンを指定して下さい。  
以下は、`test`というバージョンを指定する例です。

```bash
bash commands/docker-build.sh -v test
```

`-v`を使用しなかった場合のバージョンは`latest`となります。

<br />

## 3. burger-war-kitイメージの動作確認
### 3.1 コンテナの起動
-------------------------------------------------------------------------------
ビルドして作成したイメージからコンテナを起動するには、以下のコマンドを実行して下さい。

```bash
bash commands/docker-launch.sh
```

任意のバージョンのイメージからコンテナを起動したい場合は、`-v`オプションでバージョンを指定して下さい。  
以下は、`test`というバージョンを指定する例です。

```bash
bash commands/docker-launch.sh -v test
```

起動するコンテナ名は`burger-war-kit`となります。

<br />

### 3.2 コンテナ内でコマンドを実行
-------------------------------------------------------------------------------
コンテナ起動後は、以下のようにしてコンテナ内で任意のコマンドを実行できます。  
`-c`オプションの後に実行したいコマンドを指定して下さい。  

```bash
bash commands/kit.sh -c catkin build
```

コマンド実行時の作業ディレクトリは、`/home/developer/catkin_ws`になります。

何も引数を指定しなかった場合は、コンテナ内で`bash`を起動します。

```bash
bash commands/kit.sh
```

<br />

### 3.3 scriptsディレクトリ配下のスクリプトを実行する
-------------------------------------------------------------------------------
scriptsディレクトリ配下のスクリプトを実行したい場合は、`-s`オプションで実行するスクリプトを指定して下さい。

```bash
bash commands/kit.sh -s sim_width_judge.sh
```

コマンド実行時の作業ディレクトリは、`/home/developer/catkin_ws/burger_war_kit`になります。

<br />

## 4. 修正したDockerfileなどをGitHubにプッシュ
-------------------------------------------------------------------------------
GitHubへのプッシュなどの操作は、`git`コマンドで行っても構いませんが、VSCodeを使用すると楽になるかもしません。

以下のサイトなどを参考にして下さい。

[VSCodeでのGitの基本操作まとめ - Qiita](https://qiita.com/y-tsutsu/items/2ba96b16b220fb5913be)

<br />

## 5. GitHub Actionsによる自動ビルド＆テスト
### 5.1 自動ビルド・テストの実行トリガ
-------------------------------------------------------------------------------
自動ビルド＆テストは、以下のファイルの修正をプッシュした際に実行されます。

- `docker/**`
- `scripts/**`
- `judge/**`
- `burger_war/**`
- `.github/workflows/image-test.yml`
  
自動ビルド＆テストは、どのブランチへプッシュしても実行されます。

<br />

### 5.2 自動ビルド・テストで行っている処理
-------------------------------------------------------------------------------
GitHub Actionsで行う処理は、主な処理は以下になります。

1. burger-war-kitイメージのビルド(`docker build`)
2. 仮想ディスプレイの起動(`Xvfb`)
3. burger-war-kitコンテナ起動(`docker run`)
4. ロボコンプロジェクトのビルド(`catkin build`)
5. burger-war-kitのテスト(`scripts/sim_run_test.sh`)
6. テスト実行ログの保存(`GitHub Artifact`)
7. burger-war-kitrイメージをテスト版としてプッシュ(`docker push`)
8. テストにパスしたバージョンをファイルに保存(`TEST_VERSION`)

実際の処理は`.github/workflows/image-test.yml`を参照して下さい。

<br />

### 5.3 判定方法とログファイル
-------------------------------------------------------------------------------

<br />

## 6. GitHub Actionsでビルドされたburger-war-kitイメージ(テスト版)を使って動作確認
### 6.1 テスト版のburger-war-kitイメージを取得
-------------------------------------------------------------------------------
以下のコマンドで、テストにパスしたburger-war-kitイメージを取得して下さい。  
末尾の`test.XXX`の`XXX`には、実際にテストを実行したGitHub Actionsの番号(#XXX)を指定して下さい。

```
docker pull ghcr.io/p-robotics-hub/burger-war-kit:test.XXX
```

例えば、以下のGitHub Actionsでテストを実施したburger-war-kitイメージは`test.4`となります。  
(ページ見出しの`Kit Docker Image Build & Test #4`の`#`以降の番号)

[自動テストのサンプルページ](https://github.com/p-robotics-hub/burger_war_kit/actions/runs/577614010)

実際にプッシュされているburger-war-kitイメージのバージョンは、以下のページで確認できます。

[ghcr.ioでのburger-war-kitイメージ](https://github.com/orgs/p-robotics-hub/packages/container/package/burger-war-kit)

<br />

### 6.2 burger-war-kitイメージの動作確認
-------------------------------------------------------------------------------
コンテナ起動時に`-r`(ghcr.ioからプル)を指定し、`-v`で動作を確認したいテストバージョンを指定して下さい。

```
bash commands/docker-launch.sh -r -v test.4
```

あとは、通常の操作(kit.shなど)で動作確認が行って下さい。

<br />

### 6.3 burger-war-devイメージの動作確認
-------------------------------------------------------------------------------
`$HOME/catkin_ws/src/burger_war_dev`へ移動して、以下のように、`-k`でテストバージョンを指定して下さい。

```
bash commands/docker-build.sh -k test.4
```

あとは、通常通りコンテナを起動して動作確認を行って下さい。

```
bash commands/docker-launch.sh
```

<br />

## 7. burger-war-kitイメージをリリース
以下のページを開いて下さい。

[burger_war_kitのworkflows](https://github.com/p-robotics-hub/burger_war_kit/actions)

開いたページ右側の「Workflows」から「Release Kit Image」を選択して、「Run workflow」をクリックすると、以下のように必要な情報の入力フォームが表示されます。

![リリース用workflow](https://user-images.githubusercontent.com/76457573/109125137-0d2cca80-778f-11eb-9716-0d4e50eca375.png)


以下の必要な項目を設定して、「Run workflow」をクリックして下さい。

- Use workflow form： workflowを実行するブランチを指定(通常はmainを選択して下さい)
- テスト実施バージョン： バージョンを付与するテスt実施バージョン(`test.N`)を指定して下さい
- 付与するリリースバージョン： `4.N.n`の形式でバージョンを指定して下さい
- latestバージョンを付与するか： `yes`指定時、`latest`バージョンとして公開します
- 入力値のFormatチェックを行うか： `yes`指定時、誤ったバージョンの付与を防ぐ為、入力されたバージョンのFormatをチェックします

burger-war-kitイメージを`latest`バージョンとして公開した後は、burger_war_devで利用されるようになります。


## 補足
### A. Personal access token の作成
-------------------------------------------------------------------------------

burger-war-kitイメージをdocker-push.shを使用してghcr.ioにプッシュするためには、各自のGitHubアカウントで`Personal access token`を作成する必要があります。

以下の手順に従って、[こちらのページ](https://github.com/settings/tokens)から作成して下さい。

<br />

#### 1. Developers settings をクリック
![PAT作成手順1](https://user-images.githubusercontent.com/76457573/106542094-7fbad980-6546-11eb-8f1e-29d968c5403f.png)

<br />

#### 2. Personal access tokens の Generate new tokenをクリック
![PAT作成手順2](https://user-images.githubusercontent.com/76457573/106542236-c4467500-6546-11eb-84e8-76071223a224.png)

<br />

#### 3. Select scopes で権限設定
少なくとも以下にチェックを入れて、ページ下部にある[Generate token]をクリックして下さい。

- write:packages
- read:packages
- delete:packages

![PAT作成手順3](https://user-images.githubusercontent.com/76457573/106542385-15566900-6547-11eb-9763-c89951b94f0d.png)

<br />

##### 4. 生成された Personal access token をファイルに保存

以下のコマンドを実行して、`Personal access token`を保存するファイルを作成して下さい。

```bash
touch $HOME/.github-token
chmod 600 $HOME/.github-token
```

生成された`Personal access token`(下の画像の黒塗り部分)をコピーして、`$HOME/.github-token`に保存して下さい。

![PAT作成手順4](https://user-images.githubusercontent.com/76457573/106542405-21dac180-6547-11eb-9db1-125b09e336cf.png)

以上で、`Personal access token`の作成は完了です。

<br />

### B. 手動でghcr.ioにプッシュしたい場合
-------------------------------------------------------------------------------

#### 1. ghcr.ioへのログイン
ghcr.ioにイメージをプッシュするには、予めghcr.ioにログインしておく必要があります。

ghcr.ioにログインするには、以下のコマンドを実行して下さい。

```bash
bash commands/docker-login.sh
```

このスクリプトには`Personal access token`を保存した`$HOME/.github-token`が必要です。

予め[こちらの手順](#personal-access-token-の作成)を実施して、作成して下さい。

<br />

#### 2. burger-war-kitイメージをghcr.ioへプッシュ
ghcr.ioにイメージをプッシュするには、以下のコマンドを実行します。  
※

```bash
bash commands/docker-push.sh                    # バージョン未指定(burger-war-kit:latestになる)
bash commands/docker-push.sh   -v 202101302145  # バージョン指定時(burger-war-kit:202101302145になる)
```

プッシュしたイメージは、以下のページから確認できます。

[https://github.com/orgs/p-robotics-hub/packages/container/package/burger-war-kit]

<br />

#### 補足) 既に同じバージョンが存在する場合
既に同じバージョンのイメージがghcr.ioに登録されている場合は、後からプッシュしたものが古いイメージと置き換えられます。

古いイメージはghcr.io上に残りますが、利用したい場合は以下のようにハッシュ値を指定する必要があります。

```
docker pull ghcr.io/p-robotics-hub/burger-war-kit@sha256:9c337a0021be4b8a24cd8b9b3c2d976b876e6fb611bedb17bde1f7aa7b9579f1
```

DockerfileのFROM命令で指定する場合も同様です。

```
FROM ghcr.io/p-robotics-hub/burger-war-kit@sha256:9c337a0021be4b8a24cd8b9b3c2d976b876e6fb611bedb17bde1f7aa7b9579f1
```

<br />

#### 補足) ローカルのファイルだけ更新したい場合
もし、ghcr.ioへプッシュせずにローカルにあるイメージのバージョンだけ更新した場合は、`-l`オプションを付けてください。

```bash
bash commands/docker-push.sh -l
```

以下のように
```
REPOSITORY                                      TAG                    IMAGE ID       CREATED              SIZE
burger-war-kit                                  202101302145           a8b2cdb5fbdd   About a minute ago   3.45GB
ghcr.io/p-robotics-hub/burger-war-kit           202101302145           a8b2cdb5fbdd   About a minute ago   3.45GB
```

<br />

### C. スクリプト用共通設定ファイル
-------------------------------------------------------------------------------
commandsディレクトリ以下のスクリプトの共通変数は`commands/config.sh`に集約しています。  
具体的には以下のような変数により設定を変更できます。

```bash
#----------------------------------------------------------
# Repository config values
#----------------------------------------------------------
# Dockerイメージを登録するレジストリのURL
# $REGISTRY_URL/$KIT_DOCKER_IMAGE_NAME[:version] がURLとなる
REGISTRY_ROOT=ghcr.io
REGISTRY_URL=${REGISTRY_ROOT}/p-robotics-hub

# Dockerイメージ名
KIT_DOCKER_IMAGE_NAME=burger-war-kit
KIT_DOCKER_CONTAINER_NAME=${KIT_DOCKER_IMAGE_NAME}

#----------------------------------------------------------
# Local config values
#----------------------------------------------------------
# 開発者ユーザー名 (変更する場合はburger_war_devも見直すこと)
DEVELOPER_NAME=developer

# GitHubのPersonal access tokensを保存したファイルのパス
GITHUB_TOKEN_FILE=${HOME}/.github-token

# ワークスペースのrootディレクトリのパス
HOST_WS_DIR=${HOME}/catkin_ws

# コンテナ上のワークスペースディレクトリ
CONTAINER_WS_DIR=/home/${DEVELOPER_NAME}/catkin_ws

# ワークスペースのsrcディレクトリのパス
BURGER_WAR_KIT_DIR=${HOST_WS_DIR}/src/burger_war_kit

# ビルドするDockerfileパス
DOCKER_ROOT_DIR=${BURGER_WAR_KIT_DIR}/docker
KIT_DOCKER_FILE_PATH=${DOCKER_ROOT_DIR}/kit/Dockerfile
```

ただし、以下の変数については`burger_war_dev`リポジトリにも影響する為、大会期間中は変更はしないで下さい。

- REGISTRY_ROOT
- REGISTRY_URL
- KIT_DOCKER_IMAGE_NAME
- DEVELOPER_NAME

<br />
