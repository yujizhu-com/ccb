#!/bin/bash
# function XXXX{}
# function XXXX(){}
# XXXX(){}
#rm -rf "$1";

# _DeleteEmpty1P(){if [ -d "$1" ] && [ -z `ls -A "$1"` ];then rm -rf "$1";echo "空目录,删";elif [ ! -s "$1" ] ; then rm -rf "$1";echo "空文件,删"; else echo "非空,不删"; fi; }
#参数1为空时,删除参数1
_DeleteEmpty1P(){ if [ -d "$1" ] && [ -z `ls -A "$1"` ];then rm -rf "$1";elif [ ! -s "$1" ] ; then rm -rf "$1";fi; }
# 参数1为空时,删除参数2
_DeleteEmpty2P(){ if [ -d "$1" ] && [ -z `ls -A "$1"` ];then rm -rf "$2";elif [ ! -s "$1" ] ; then rm -rf "$2";fi; }
#回收
_Recycle(){ 
	if [[ "$1" =~ ^/Users/yujizhu/Documents/Git/* ]] ;
	then 
		if [ ! -e "/Users/yujizhu/Trash" ] ;then mkdir "/Users/yujizhu/Trash";fi;
		if [ -e $1 ] ;then cp -r "$1" "/Users/yujizhu/Trash";rm -rf "$1";fi;
	else echo "非法目录";exit;
	fi;
}
#先回收,再清空
_Delete(){ _Recycle "$1";rm -rf "$1";}
#先回收,再清空
_Clear(){ _Recycle "$1";if [ -s "$1" ];then rm -f "$1";fi;touch "$1"; }
#先回收,再新建
# -e 文件目录是否存在 -d 是否是目录 -f 是否是目录和设备文件外的普通文件
_New(){ _Recycle "$1";if [[ "$1" =~ ^.*/[^\.]+$ ]];then mkdir "$1";elif [[ "$1" =~ ^.*/?\..+$ ]];then touch "$1";fi; }
#若无回收站,则结束进程
_CheckTrash(){ if [ ! -e "/Users/yujizhu/Trash" ] ;then echo "回收站不存在";exit;fi; }
#若非工作目录,则结束进程
_CheckWorkDir(){ if [[ ! "$1" =~ ^/Users/yujizhu/Documents/Git/* ]] ; then echo "操作目录不合法";eixt ;fi; }
Main()
{
	_CheckTrash
	read -p 拖入文件夹: DIR
	_CheckWorkDir $DIR
	local SHDIR="/Users/yujizhu/Documents/Git/MyHD/bin/ccb"
	cd "$DIR"

	local SORTDIR="$DIR/^sort";_New ${SORTDIR}

	local SPINEDIR="$SORTDIR/_spine";_New ${SPINEDIR}

	local FONTDIR="$SORTDIR/_font";_New ${FONTDIR}
	local FONT_TXT=$FONTDIR/_font.txt;_New $FONT_TXT

	local IMGDIR="$SORTDIR/_img";_New $IMGDIR

	local OGGDIR="$SORTDIR/_ogg";_New $OGGDIR

	local MP3DIR="$SORTDIR/_mp3";_New $MP3DIR

	local ALL=$SHDIR/ALL.txt
	find . -regex ".*" | sort -k1,1  |  uniq  > "$ALL"

	local ERROR="$SORTDIR/^ERROR.txt";
	grep -E [[:space:]]+ $ALL > $ERROR
	_DeleteEmpty1P $ERROR
    
    local CCBFILES="$SHDIR/CCBFILES.txt"
    find . -regex "^.*\\.red$" | sort -k1,1  |  uniq  > "$CCBFILES"
	for i in `cat "$CCBFILES"`
	do
		local file=${i}
		local name=${file##*/}
		name=${name%.*}
		local dir=${SORTDIR}/${name} ; _New $dir

		local RES=${SORTDIR}/${name}/^RES.txt
		grep -ohE "[^\/\<\>\.]+\.(png|jpg|webp|plist)" "$file" | sort -k1  |  uniq  > "$RES"

		local ORIGIN=${SORTDIR}/${name}/^ORIGIN_RES.txt
		grep -f "$RES" "$ALL" > "$ORIGIN"
		for j in `cat "$ORIGIN"` ;do cp ${j} $dir;cp ${j} $IMGDIR;	done;

		local RES_LACK=${SORTDIR}/${name}/^RES_LACK.txt
		echo "^$" >> $ORIGIN
		grep -vf $ORIGIN $RES > $RES_LACK

		_Delete $RES 
		_Delete $ORIGIN

		local SPINE_DIR=${SORTDIR}/${name}/^spine ;_New $SPINE_DIR
		local SPINE=$SPINE_DIR/^SPINE.txt
		local SPINE_TEMP=$SPINE_DIR/^SPINE_TEMP.txt
		local SPINE_ORIGIN=$SPINE_DIR/^SPINE_ORIGIN.txt
		grep -ohE "[^\/\<\>\.]+\.(atlas|skel)" "$file" | sort -k1  |  uniq  > "$SPINE"
		grep -ohE "^[^\.]+" "$SPINE" | sort -k1  |  uniq  > "$SPINE_TEMP"
		for j in `cat "$SPINE_TEMP"`
		do
			echo "/"${j}".atlas$" >> "$SPINE"
			echo "/"${j}".skel$"  >> "$SPINE"
			echo "/"${j}".png$"   >> "$SPINE"
			echo "/"${j}".webp$"   >> "$SPINE"
		done
		grep -f "$SPINE" "$ALL" > "$SPINE_ORIGIN"
		for j in `cat "$SPINE_ORIGIN"` ; do cp ${j} $SPINE_DIR; cp ${j} $SPINEDIR; done;
		_DeleteEmpty2P ${SPINE_TEMP} ${SPINE_DIR}

		local FONT_DIR=${SORTDIR}/${name}/^font;_New $FONT_DIR
		local FONT=$FONT_DIR/^FONT.txt
		local FONT_TEMP=$FONT_DIR/^FONT_TEMP.txt
		local FONT_ORIGIN=$FONT_DIR/^FONT_ORIGIN.txt
		grep -ohE "[^\/\<\>\.]+\.(fnt)" "$file" | sort -k1  |  uniq  > "$FONT"
		grep -ohE "^[^\.]+" "$FONT" | sort -k1  |  uniq  > "$FONT_TEMP"
		for j in `cat "$FONT_TEMP"`
		do
			echo ${j}".fnt" >> "$FONT"
			echo ${j}".png"   >> "$FONT"
			echo ${j}".webp"   >> "$FONT"
		done
		grep -f "$FONT" "$ALL" > "$FONT_ORIGIN" 
		for j in `cat "$FONT_ORIGIN"`
		do
			cp ${j} $FONT_DIR
			cp ${j} $FONTDIR
		done

		local FONT_LACK=$FONT_DIR/^FONT_LACK.txt
		grep -vf $FONT $FONT_ORIGIN > $FONT_LACK
		_DeleteEmpty2P ${FONT_TEMP} ${FONT_DIR}

		local MP3_DIR=${SORTDIR}/${name}/^mp3 ; _New $MP3_DIR
		local MP3_NS_NAP=$MP3_DIR/^MP3_NS_NAP.txt
		local MP3_NAP=$MP3_DIR/^MP3_NAP.txt
		local MP3_AP=$MP3_DIR/^MP3_AP.txt
		local MP3_REGEX=$MP3_DIR/^MP3_REGEX.txt ; _New $MP3_REGEX
		grep -ohE "[^\/\<\>\.]+\.(mp3|ogg)" "$file" | sort -k1  |  uniq  > "$MP3_NAP"
		grep -ohE "^[^\.]+" "$MP3_NAP" | sort -k1  |  uniq  > "$MP3_NS_NAP"
		for j in `cat "$MP3_NS_NAP"`
		do
			echo "/"${j}".mp3$" >> "$MP3_REGEX"
		done
		grep -f "$MP3_REGEX" "$ALL" > "$MP3_AP"
		local files=`cat "$MP3_AP" | echo -n`
		for j in `cat "$MP3_AP"`
		do
			cp ${j} $MP3_DIR
			cp ${j} $MP3DIR
		done

		local MP3_LACK=$MP3_DIR/^MP3_LACK.txt
		echo ^$ >> $MP3_AP
		grep -vf $MP3_AP $MP3_NS_NAP > $MP3_LACK
		_DeleteEmpty2P ${MP3_NS_NAP} ${MP3_DIR}
		_Delete $MP3_NS_NAP	
		_Delete $MP3_NAP
		_Delete $MP3_REGEX
		_Delete $MP3_AP

		local OGG_DIR=${SORTDIR}/${name}/^ogg ; _New $OGG_DIR
		local OGG_NS_NAP=$OGG_DIR/^OGG_NS_NAP.txt
		local OGG_NAP=$OGG_DIR/^OGG_NAP.txt
		local OGG_AP=$OGG_DIR/^OGG_AP.txt
		local OGG_REGEX=$OGG_DIR/^OGG_REGEX.txt ; _New $OGG_REGEX
		grep -ohE "[^\/\<\>\.]+\.(mp3|ogg)" "$file" | sort -k1  |  uniq  > "$OGG_NAP"
		grep -ohE "^[^\.]+" "$OGG_NAP" | sort -k1  |  uniq  > "$OGG_NS_NAP"
		for j in `cat "$OGG_NS_NAP"`
		do
			echo "/"${j}".ogg$" >> "$OGG_REGEX"
		done
		grep -f "$OGG_REGEX" "$ALL" > "$OGG_AP" 
		for j in `cat "$OGG_AP"`
		do
			cp ${j} $OGG_DIR
			cp ${j} $OGGDIR
		done
		_DeleteEmpty2P ${OGG_NS_NAP} ${OGG_DIR}
	done
    exit
}
Main 