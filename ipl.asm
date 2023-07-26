CYLS equ 10             ; CYLS = 10 シリンダーをどこまで読み込むか

; hello-os
    ORG     0x7c00          ; このプログラムがどこに読み込まれるのか

; 以下は標準的なFAT12フォーマットフロッピーディスクのための記述
    JMP     entry
    DB      0x90
    DB      "HELLOIPL"      ; ブートセクタの名前を自由に書いてよい（8バイト）
    DW      512             ; 1セクタの大きさ（512にしなければいけない）
    DB      1               ; クラスタの大きさ（1セクタにしなければいけない）
    DW      1               ; FATがどこから始まるか（普通は1セクタ目からにする）
    DB      2               ; FATの個数（2にしなければいけない）
    DW      224             ; ルートディレクトリ領域の大きさ（普通は224エントリにする）
    DW      2880            ; このドライブの大きさ（2880セクタにしなければいけない）
    DB      0xf0            ; メディアのタイプ（0xf0にしなければいけない）
    DW      9               ; FAT領域の長さ（9セクタにしなければいけない）
    DW      18              ; 1トラックにいくつのセクタがあるか（18にしなければいけない）
    DW      2               ; ヘッドの数（2にしなければいけない）
    DD      0               ; パーティションを使ってないのでここは必ず0
    DD      2880            ; このドライブ大きさをもう一度書く
    DB      0,0,0x29        ; よくわからないけどこの値にしておくといいらしい
    DD      0xffffffff      ; たぶんボリュームシリアル番号
    DB      "HELLO-OS   "   ; ディスクの名前（11バイト）
    DB      "FAT12   "      ; フォーマットの名前（8バイト）
    TIMES   18 DB 0         ; とりあえず18バイトあけておく

; プログラム本体

entry:
    MOV     AX,0            ; レジスタ初期化
    MOV     SS,AX
    MOV     SP,0x7c00
    MOV     DS,AX

;ディスクを読む
    mov     ax,0x0820
    mov     es,ax
    mov     ch,0           ; シリンダ0
    mov     dh,0           ; ヘッド0
    mov     cl,2           ; セクタ2

readloop:
    mov     si,0            ; 失敗回数を数えるレジスタ
retry:
    mov     ah,0x02        ; INT13の引数(ディスク読み込み)
    mov     al,1           ; 1セクタ
    mov     bx,0
    mov     dl,0x00        ; Aドライブ
    int     0x13            ; ディスクBIOS呼び出し
    jnc     next            ; エラーなければnextへ
    add     si,1            ; カウンタインクリメント
    cmp     si,5            ; 5回まで
    jae     error           ; 5回超えてたらerrorへ
    mov     ah,0x00
    mov     dl,0x00         ; Aドライブ
    int     0x13            ; ドライブのリセット
    jmp     retry           ; ループ

next:
    mov     ax,es
    add     ax,0x0020
    mov     es,ax           ; esに0x20を足す (0x20 = 512 / 16)
    add     cl,1            ; clに1を足す
    cmp     cl,18
    jbe     readloop        ; cl <= 18ならreadloopへ 
    mov     cl,1            ; セクタをリセット（シリンダorヘッドが移るので）
    add     dh,1            ; ヘッドを裏側へ
    cmp     dh,2            ; dh(ヘッド)が2より小さければ(0or1なら)大丈夫なのでreadloopに
    jb      readloop
    mov     dh,0            ; dh >= 2 なら dh = 1
    add     ch,1            ; 裏から表に戻ってきたってことなので新しいシリンダに
    cmp     ch,CYLS         ; 読み込みシリンダ数と比べる
    jb      readloop        ; ch < CYLS ならreadloopへ

; 読み終わったので os.sys を実行
    mov     [0x0ff0],ch     ; os.sysにCYLSの値を教える
    jmp     0xc200

fin:
    HLT                     ; 何かあるまでCPUを停止させる
    JMP     fin             ; 無限ループ

error:
    MOV     SI,msg

putloop:
    MOV     AL,[SI]
    ADD     SI,1            ; SIに1を足す
    CMP     AL,0            ; 0x00 (終端) が来たら終わる
    JE      fin
    MOV     AH,0x0e         ; 一文字表示ファンクション
    MOV     BX,15           ; カラーコード
    INT     0x10            ; ビデオBIOS呼び出し
    JMP     putloop

msg:
    DB      0x0a, 0x0a      ; 改行を2つ
    DB      "loading error"
    DB      0x0a            ; 改行
    DB      0x00            ; 終端

    TIMES   0x7dfe-($-$$)-0x7c00 DB 0        ; 0x7dfeまでを0x00で埋める命令

    DB      0x55, 0xaa
