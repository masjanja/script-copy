#!/bin/bash

#количество тестовых пользоватнлей
user=4
#множитель для задания размера папки
multiplier=3


src=../src/wst01
dst=../dst/home

mkdir -p $dst
mkdir -p $src

#функция создания тестовой папки с данными
create_data_dir(){
    mkdir -p $2
    for ((i=1;i<(( 100 * $1 ));i++))
    do
    dd if=/dev/zero of=$2/$i-file-1M bs=1M count=1
    done

    for ((i=1;i<((1000 * $1 ));i++))
    do
    dd if=/dev/zero of=$2/$i-file-1K bs=1K count=1
    done    

    for ((i=1;i<(( 10 * $1 ));i++))
    do
    dd if=/dev/zero of=$2/$i-file-100M bs=1M count=100
    done

    for ((i=1;i<(( 1 * $1 ));i++))
    do
    dd if=/dev/zero of=$2/$i-file-1000M bs=1M count=1000
    done
}

for ((b=1;b<=$user;b++))
do
    echo "множитель: $multiplier, пользователь: user$b"
    create_data_dir $multiplier "$src/user0$b/"  >> $src/user0$b.log 2>&1
    
done

#создаём папку локаоьного пользоваьеля для тестовой среды
create_data_dir $multiplier "$src/$USER" >> $src/$USER.log 2>&1