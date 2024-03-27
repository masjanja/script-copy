#!/bin/bash

#указываем целевую директорию
dst=../dst/

#смотрим имя компа и записываем в переменную
#wst=`hostname -s`
#т.к. тестовая среда, то укажем руками
wst="wst01"

#задаём путь, где лежит бэкап
src=../src/$wst

#файл с логом
log_file=copy.log


#определяем пользователей, которые работали за этим компом
users=`ls $src`

#создаём файл шаблона для awk
awk_template="rsync.awk"
echo "ewogICBpZiAoaW5kZXgoJDAsICJ0by1jaGs9IikgPiAwKQogICB7CglzcGxpdCgkMCwgc3RyaW5nLCAiICIpCiAgIHByaW50IHN0cmluZ1sxXTsKCXNwbGl0KHN0cmluZ1syXSwgZmlsZXMsICJ0by1jaGs9Iik7CiAgIHByaW50ICIjINC+0YHRgtCw0LvQvtGB0Ywg0YHQutC+0L/QuNGA0L7QstCw0YLRjCDRhNCw0LnQu9C+0LIgIiBmaWxlc1syXSAiINGB0LrQvtGA0L7RgdGC0Ywg0LrQvtC/0LjRgNC+0LLQsNC90LjRjyAiIHN0cmluZ1szXSAiINGB0LrQvtC/0LjRgNC+0LLQsNC90L4g0LTQsNC90L3Ri9GFICJzdHJpbmdbNF0gIiAvICIgc3RyaW5nWzFdICIlICIgIiDQstGA0LXQvNGPINC60L7Qv9C40YDQvtCy0LDQvdC40Y8gInN0cmluZ1s1XTsKCiAgIH0KICAgZWxzZQogICB7CglwcmludCAiIyIkMDsKICAgfQogICBmZmx1c2goKTsKfQ==" | base64 -d > $awk_template


#определяем наличие пользователей в системе и возвращаем номер сеанса при наличии
function get_display_user() {
        display=$(who | grep $1 | awk '{print $5}' | grep ":" | tr -d "()")
        echo "$display"
}


#функция копирования
function copy_data(){
    #проверяем наличие пользовате в системе
    if [[ $2 == "NONE" ]]; then
        #если пользователь не в системе, то копируем тихо
        rsync -az --info=progress2 -h $src/$1 $dst
    else
        #исли пользователь в системе, то выводим сообщение на экран
        #вычисляем размер данных
        size_dir_user=$(du -h $src/$1 | awk '{print $1}')
        echo "размер данных пользователя: $size_dir_user"
        #get_time_awaited=$(time_copy $size )
        rsync -az --info=progress2 -h $src/$1 $dst | \
        tr '\r' '\n' | tr -d '%' | awk '{print $2, $6, $3, $1, $4}' | tr -d ')' | \
        awk -f $awk_template | \
        DIPLAY="$2" zenity --progress --width=550 --title  "Копирование файлов $1" --percentage=0 --auto-kill --auto-close --no-cancel
    fi
}



for i in $users
do
    display=$(get_display_user $i)
    #echo "diplay=$display"
    if [[ -n $display ]]; then
        #echo "User $i login"
        copy_data $i $display
    else
        #echo "User $i not login"
        copy_data $i NONE
    fi
done
rm $awk_template
