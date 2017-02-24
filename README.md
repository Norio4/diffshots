# Diffshots
====

Overview

## Description

yaml形式でurlをセットしておくことで、２つのサイトのスクリーンショットを撮影し、差分抽出、どこが変化しているかまで自動でやります。

### yamlの書き方

originとcomparisonを並べ、urlsの下にurlの配列を記述してください。

　　　　"origin":
    
　　　　　　　　"urls":
        
　　　　　　　　　　　　- "http://google.co.jp/"
            
　　　　　　　　　　　　- "https://ja.wikipedia.org/wiki/Ruby"
            
　　　　"comparison":
    
　　　　　　　　"urls":
        
　　　　　　　　　　　　- "http://yahoo.co.jp/"
            
　　　　　　　　　　　　- "https://ja.wikipedia.org/wiki/Python"


## Requirement

-Cento7

 
## Usage
  `ruby diff_shots.rb -f example.yml `
  
  `ruby diff_shots.rb -h `
 
＊ymlファイルを指定しない場合、carrent directoryの全ymlファイルを対象にします。

## Install


(1)ページ撮影後、ブラウザで確認したい場合
 - `sh build_env_with_nodejs`

(2)ページ撮影後、Finder等で確認したい場合
 - `sh build_env_only_shot`

＊(1)を実行するとnodejsも自動でインストール＋環境構築します。

## Contribution

## Licence

[MIT](https://github.com/tcnksm/tool/blob/master/LICENCE)

## Author

[Norio4](https://github.com/norio4)
