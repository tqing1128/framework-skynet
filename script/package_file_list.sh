#!/bin/bash

show_help() {
    cat << EOF
Usage: ${0##*/} [options]

Options:
  -h, --help                展示帮助
  -r, --root_dir            打包主目录
  -c, --include_config      打包配置文件名，默认为 package_include，一行一项配置:
                                1. 配置项为文件
                                2. 配置项为目录
                                3. 使用子目录中的 package_include，成对使用下面配置
                                    -C{dir_name}
                                    -T{package_config}
EOF
}

while [ $# -gt 0 ]
do
    case $1 in
        -h|--help)
            show_help
            exit 1
            ;;
        -r|--root-dir)
            ARGS_ROOT_DIR=${2}
            shift 2
            ;;
        -c|--include-config)
            ARGS_INCLUDE_CONFIG=${2}
            shift 2
            ;;
        *)
            show_help
            exit 1
            ;;
    esac
done

if [ -z "${ARGS_ROOT_DIR}" ]; then
    show_help
    exit 1
fi

ARGS_INCLUDE_CONFIG=${ARGS_INCLUDE_CONFIG:-"package_include"}

cd "${ARGS_ROOT_DIR}" || exit 1

file_path_list=()

function genlist() {
    local dir=${1}
    local include_config=${2}
    local list=($(cat "${dir}${include_config}"))
    local sub_dir
    for file_path in "${list[@]}"
    do
        local label="$(echo "${file_path}" | sed 's/\(^\-[CT]\).*/\1/g')"
        local path="$(echo "${file_path}" | sed 's/^\-[CT]\(.*\)/\1/g')"
        if [ "-C" == "${label}" ]; then
            sub_dir=${path}/
        elif [ "-T" == "${label}" ]; then
            local sub_include_config=${path}
            genlist "${dir}${sub_dir}" "${sub_include_config}"
            sub_dir=
        else
            local prefix=${dir}
            file_path_list[${#file_path_list[*]}]=${prefix}${file_path}
        fi
    done
}

genlist "" "${ARGS_INCLUDE_CONFIG}"

echo "${file_path_list[@]}"