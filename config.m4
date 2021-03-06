dnl $Id$
dnl config.m4 for extension swoole

dnl  +----------------------------------------------------------------------+
dnl  | Swoole                                                               |
dnl  +----------------------------------------------------------------------+
dnl  | This source file is subject to version 2.0 of the Apache license,    |
dnl  | that is bundled with this package in the file LICENSE, and is        |
dnl  | available through the world-wide-web at the following url:           |
dnl  | http://www.apache.org/licenses/LICENSE-2.0.html                      |
dnl  | If you did not receive a copy of the Apache2.0 license and are unable|
dnl  | to obtain it through the world-wide-web, please send a note to       |
dnl  | license@swoole.com so we can mail you a copy immediately.            |
dnl  +----------------------------------------------------------------------+
dnl  | Author: Tianfeng Han  <mikan.tenny@gmail.com>                        |
dnl  +----------------------------------------------------------------------+

PHP_ARG_ENABLE(debug-log, whether to enable debug log,
[  --enable-debug-log        Enable swoole debug log], no, no)

PHP_ARG_ENABLE(trace-log, Whether to enable trace log,
[  --enable-trace-log        Enable swoole trace log], no, no)

PHP_ARG_ENABLE(sockets, enable sockets support,
[  --enable-sockets          Do you have sockets extension?], no, no)

PHP_ARG_ENABLE(openssl, enable openssl support,
[  --enable-openssl          Use openssl?], no, no)

PHP_ARG_ENABLE(http2, enable http2.0 support,
[  --enable-http2            Use http2.0?], no, no)

PHP_ARG_ENABLE(swoole, swoole support,
[  --enable-swoole           Enable swoole support], [enable_swoole="yes"])

PHP_ARG_ENABLE(mysqlnd, enable mysqlnd support,
[  --enable-mysqlnd          Do you have mysqlnd?], no, no)

PHP_ARG_ENABLE(coroutine-postgresql, enable coroutine postgresql support,
[  --enable-coroutine-postgresql    Do you install postgresql?], no, no)

PHP_ARG_ENABLE(cares, enable c-ares support,
[  --enable-cares            Use cares?], no, no)

PHP_ARG_WITH(cares_dir, dir of c-ares,
[  --with-cares-dir[=DIR]      Include c-ares support], no, no)

PHP_ARG_WITH(openssl_dir, dir of openssl,
[  --with-openssl-dir[=DIR]    Include OpenSSL support (requires OpenSSL >= 0.9.6)], no, no)

PHP_ARG_WITH(nghttp2_dir, dir of nghttp2,
[  --with-nghttp2-dir[=DIR]    Include nghttp2 support], no, no)

PHP_ARG_WITH(phpx_dir, dir of php-x,
[  --with-phpx-dir[=DIR]       Include PHP-X support], no, no)

PHP_ARG_WITH(jemalloc_dir, dir of jemalloc,
[  --with-jemalloc-dir[=DIR]   Include jemalloc support], no, no)

PHP_ARG_WITH(libpq_dir, dir of libpq,
[  --with-libpq-dir[=DIR]      Include libpq support (requires libpq >= 9.5)], no, no)

PHP_ARG_ENABLE(asan, whether to enable asan,
[  --enable-asan             Enable asan], no, no)

PHP_ARG_ENABLE(picohttpparser, enable picohttpparser support,
[  --enable-picohttpparser   Experimental: Do you have picohttpparser?], no, no)

AC_DEFUN([SWOOLE_HAVE_PHP_EXT], [
    extname=$1
    haveext=$[PHP_]translit($1,a-z_-,A-Z__)

    AC_MSG_CHECKING([for ext/$extname support])
    if test -x "$PHP_EXECUTABLE"; then
        grepext=`$PHP_EXECUTABLE -m | $EGREP ^$extname\$`
        if test "$grepext" = "$extname"; then
            [PHP_HTTP_HAVE_EXT_]translit($1,a-z_-,A-Z__)=1
            AC_MSG_RESULT([yes])
            $2
        else
            [PHP_HTTP_HAVE_EXT_]translit($1,a-z_-,A-Z__)=
            AC_MSG_RESULT([no])
            $3
        fi
    elif test "$haveext" != "no" && test "x$haveext" != "x"; then
        [PHP_HTTP_HAVE_EXT_]translit($1,a-z_-,A-Z__)=1
        AC_MSG_RESULT([yes])
        $2
    else
        [PHP_HTTP_HAVE_EXT_]translit($1,a-z_-,A-Z__)=
        AC_MSG_RESULT([no])
        $3
    fi
])

AC_DEFUN([AC_SWOOLE_CPU_AFFINITY],
[
    AC_MSG_CHECKING([for cpu affinity])
    AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[
        #ifdef __FreeBSD__
        #include <sys/types.h>
        #include <sys/cpuset.h>
        typedef cpuset_t cpu_set_t;
        #else
        #include <sched.h>
        #endif
    ]], [[
        cpu_set_t cpu_set;
        CPU_ZERO(&cpu_set);
    ]])],[
        AC_DEFINE([HAVE_CPU_AFFINITY], 1, [cpu affinity?])
        AC_MSG_RESULT([yes])
    ],[
        AC_MSG_RESULT([no])
    ])
])

AC_DEFUN([AC_SWOOLE_HAVE_REUSEPORT],
[
    AC_MSG_CHECKING([for socket REUSEPORT])
    AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[
        #include <sys/socket.h>
    ]], [[
        int val = 1;
        setsockopt(0, SOL_SOCKET, SO_REUSEPORT, &val, sizeof(val));
    ]])],[
        AC_DEFINE([HAVE_REUSEPORT], 1, [have SO_REUSEPORT?])
        AC_MSG_RESULT([yes])
    ],[
        AC_MSG_RESULT([no])
    ])
])

AC_DEFUN([AC_SWOOLE_HAVE_FUTEX],
[
    AC_MSG_CHECKING([for futex])
    AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[
        #include <linux/futex.h>
        #include <syscall.h>
        #include <unistd.h>
    ]], [[
        int futex_addr;
        int val1;
        syscall(SYS_futex, &futex_addr, val1, NULL, NULL, 0);
    ]])],[
        AC_DEFINE([HAVE_FUTEX], 1, [have FUTEX?])
        AC_MSG_RESULT([yes])
    ],[
        AC_MSG_RESULT([no])
    ])
])

AC_DEFUN([AC_SWOOLE_HAVE_UCONTEXT],
[
    AC_MSG_CHECKING([for ucontext])
    AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[
        #include <stdio.h>
        #include <ucontext.h>
        #include <unistd.h>
    ]], [[
        ucontext_t context;
        getcontext(&context);
    ]])],[
        AC_DEFINE([HAVE_UCONTEXT], 1, [have ucontext?])
        AC_MSG_RESULT([yes])
    ],[
        AC_MSG_RESULT([no])
    ])
])

AC_DEFUN([AC_SWOOLE_HAVE_BOOST_CONTEXT],
[
    AC_MSG_CHECKING([for boost.context])
    AC_LANG([C++])
    AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[
        #include <boost/context/all.hpp>
    ]], [[

    ]])],[
        AC_DEFINE([HAVE_BOOST_CONTEXT], 1, [have boost.context?])
        SW_HAVE_BOOST_CONTEXT=yes
        AC_MSG_RESULT([yes])
    ],[
        AC_MSG_RESULT([no])
    ])
])

AC_DEFUN([AC_SWOOLE_HAVE_VALGRIND],
[
    AC_MSG_CHECKING([for valgrind])
    AC_LANG([C++])
    AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[
        #include <valgrind/valgrind.h>
    ]], [[

    ]])],[
        AC_DEFINE([HAVE_VALGRIND], 1, [have valgrind?])
        AC_MSG_RESULT([yes])
    ],[
        AC_MSG_RESULT([no])
    ])
])

AC_MSG_CHECKING([if compiling with clang])
AC_COMPILE_IFELSE([
    AC_LANG_PROGRAM([], [[
        #ifndef __clang__
            not clang
        #endif
    ]])],
    [CLANG=yes], [CLANG=no]
)
AC_MSG_RESULT([$CLANG])

if test "$CLANG" = "yes"; then
    CFLAGS="$CFLAGS -std=gnu89"
fi

AC_CANONICAL_HOST

if test "$PHP_SWOOLE" != "no"; then

    AC_CHECK_LIB(c, accept4, AC_DEFINE(HAVE_ACCEPT4, 1, [have accept4]))
    AC_CHECK_LIB(c, signalfd, AC_DEFINE(HAVE_SIGNALFD, 1, [have signalfd]))
    AC_CHECK_LIB(c, eventfd, AC_DEFINE(HAVE_EVENTFD, 1, [have eventfd]))
    AC_CHECK_LIB(c, epoll_create, AC_DEFINE(HAVE_EPOLL, 1, [have epoll]))
    AC_CHECK_LIB(c, poll, AC_DEFINE(HAVE_POLL, 1, [have poll]))
    AC_CHECK_LIB(c, sendfile, AC_DEFINE(HAVE_SENDFILE, 1, [have sendfile]))
    AC_CHECK_LIB(c, kqueue, AC_DEFINE(HAVE_KQUEUE, 1, [have kqueue]))
    AC_CHECK_LIB(c, backtrace, AC_DEFINE(HAVE_EXECINFO, 1, [have execinfo]))
    AC_CHECK_LIB(c, daemon, AC_DEFINE(HAVE_DAEMON, 1, [have daemon]))
    AC_CHECK_LIB(c, mkostemp, AC_DEFINE(HAVE_MKOSTEMP, 1, [have mkostemp]))
    AC_CHECK_LIB(c, inotify_init, AC_DEFINE(HAVE_INOTIFY, 1, [have inotify]))
    AC_CHECK_LIB(c, malloc_trim, AC_DEFINE(HAVE_MALLOC_TRIM, 1, [have malloc_trim]))
    AC_CHECK_LIB(c, inotify_init1, AC_DEFINE(HAVE_INOTIFY_INIT1, 1, [have inotify_init1]))
    AC_CHECK_LIB(c, gethostbyname2_r, AC_DEFINE(HAVE_GETHOSTBYNAME2_R, 1, [have gethostbyname2_r]))
    AC_CHECK_LIB(c, ptrace, AC_DEFINE(HAVE_PTRACE, 1, [have ptrace]))
    AC_CHECK_LIB(pthread, pthread_rwlock_init, AC_DEFINE(HAVE_RWLOCK, 1, [have pthread_rwlock_init]))
    AC_CHECK_LIB(pthread, pthread_spin_lock, AC_DEFINE(HAVE_SPINLOCK, 1, [have pthread_spin_lock]))
    AC_CHECK_LIB(pthread, pthread_mutex_timedlock, AC_DEFINE(HAVE_MUTEX_TIMEDLOCK, 1, [have pthread_mutex_timedlock]))
    AC_CHECK_LIB(pthread, pthread_barrier_init, AC_DEFINE(HAVE_PTHREAD_BARRIER, 1, [have pthread_barrier_init]))
    AC_CHECK_LIB(pcre, pcre_compile, AC_DEFINE(HAVE_PCRE, 1, [have pcre]))
    AC_CHECK_LIB(pq, PQconnectdb, AC_DEFINE(HAVE_POSTGRESQL, 1, [have postgresql]))
    AC_CHECK_LIB(cares, ares_library_init, AC_DEFINE(HAVE_CARES, 1, [have c-ares]))
    AC_CHECK_LIB(nghttp2, nghttp2_hd_inflate_new, AC_DEFINE(HAVE_NGHTTP2, 1, [have nghttp2]))

    AC_CHECK_LIB(brotlienc, BrotliEncoderCreateInstance, [
        AC_DEFINE(SW_HAVE_BROTLI, 1, [have brotli])
        PHP_ADD_LIBRARY(brotlienc, 1, SWOOLE_SHARED_LIBADD)
    ])

    AC_CHECK_LIB(z, gzgets, [
        AC_DEFINE(SW_HAVE_ZLIB, 1, [have zlib])
        PHP_ADD_LIBRARY(z, 1, SWOOLE_SHARED_LIBADD)
    ])

    PHP_ADD_LIBRARY(pthread)
    PHP_SUBST(SWOOLE_SHARED_LIBADD)

    AC_ARG_ENABLE(debug,
        [  --enable-debug,         compile with debug symbols],
        [PHP_DEBUG=$enableval],
        [PHP_DEBUG=0]
    )

    if test "$PHP_DEBUG_LOG" != "no"; then
        AC_DEFINE(SW_DEBUG, 1, [do we enable swoole debug])
        PHP_DEBUG=1
    fi

    if test "$PHP_ASAN" != "no"; then
        PHP_DEBUG=1
        CFLAGS="$CFLAGS -fsanitize=address -fno-omit-frame-pointer"
    fi

    if test "$PHP_TRACE_LOG" != "no"; then
        AC_DEFINE(SW_LOG_TRACE_OPEN, 1, [enable trace log])
    fi

    if test "$PHP_SOCKETS" = "yes"; then
        AC_MSG_CHECKING([for php_sockets.h])

        AS_IF([test -f $abs_srcdir/ext/sockets/php_sockets.h], [AC_MSG_RESULT([ok, found in $abs_srcdir])],
            [test -f $phpincludedir/ext/sockets/php_sockets.h], [AC_MSG_RESULT([ok, found in $phpincludedir])],
            [AC_MSG_ERROR([cannot find php_sockets.h. Please check if sockets extension is installed.])
        ])

        AC_DEFINE(SW_SOCKETS, 1, [enable sockets support])

        dnl Some systems build and package PHP socket extension separately
        dnl and php_config.h does not have HAVE_SOCKETS defined.
        AC_DEFINE(HAVE_SOCKETS, 1, [whether sockets extension is enabled])

        PHP_ADD_EXTENSION_DEP(swoole, sockets, true)
    fi

    if test "$PHP_THREAD" = "yes"; then
        AC_DEFINE(SW_USE_THREAD, 1, [enable thread support])
    fi

    AC_SWOOLE_CPU_AFFINITY
    AC_SWOOLE_HAVE_REUSEPORT
    AC_SWOOLE_HAVE_FUTEX
    AC_SWOOLE_HAVE_UCONTEXT
    AC_SWOOLE_HAVE_BOOST_CONTEXT
    AC_SWOOLE_HAVE_VALGRIND

    AS_CASE([$host_os],
      [darwin*], [SW_OS="MAC"],
      [cygwin*], [SW_OS="CYGWIN"],
      [mingw*], [SW_OS="MINGW"],
      [linux*], [SW_OS="LINUX"],
      []
    )

    CFLAGS="-Wall -pthread $CFLAGS"
    LDFLAGS="$LDFLAGS -lpthread"

    if test "$SW_OS" = "MAC"; then
        AC_CHECK_LIB(c, clock_gettime, AC_DEFINE(HAVE_CLOCK_GETTIME, 1, [have clock_gettime]))
    else
        AC_CHECK_LIB(rt, clock_gettime, AC_DEFINE(HAVE_CLOCK_GETTIME, 1, [have clock_gettime]))
        PHP_ADD_LIBRARY(rt, 1, SWOOLE_SHARED_LIBADD)
    fi
    if test "$SW_OS" = "LINUX"; then
        LDFLAGS="$LDFLAGS -z now"
    fi

    if test "$PHP_OPENSSL" != "no" || test "$PHP_OPENSSL_DIR" != "no"; then
        if test "$PHP_OPENSSL_DIR" != "no"; then
            AC_DEFINE(HAVE_OPENSSL, 1, [have openssl])
            PHP_ADD_INCLUDE("${PHP_OPENSSL_DIR}/include")
            PHP_ADD_LIBRARY_WITH_PATH(ssl, "${PHP_OPENSSL_DIR}/${PHP_LIBDIR}")
        else
            AC_CHECK_LIB(ssl, SSL_connect, AC_DEFINE(HAVE_OPENSSL, 1, [have openssl]))
        fi

        AC_DEFINE(SW_USE_OPENSSL, 1, [enable openssl support])
        PHP_ADD_LIBRARY(ssl, 1, SWOOLE_SHARED_LIBADD)
        PHP_ADD_LIBRARY(crypto, 1, SWOOLE_SHARED_LIBADD)
    fi

    if test "$PHP_PHPX_DIR" != "no"; then
        PHP_ADD_INCLUDE("${PHP_PHPX_DIR}/include")
        PHP_ADD_LIBRARY_WITH_PATH(phpx, "${PHP_PHPX_DIR}/${PHP_LIBDIR}")
        AC_DEFINE(SW_USE_PHPX, 1, [enable PHP-X support])
        PHP_ADD_LIBRARY(phpx, 1, SWOOLE_SHARED_LIBADD)
    fi

    if test "$PHP_JEMALLOC_DIR" != "no"; then
        AC_DEFINE(SW_USE_JEMALLOC, 1, [use jemalloc])
        PHP_ADD_INCLUDE("${PHP_JEMALLOC_DIR}/include")
        PHP_ADD_LIBRARY_WITH_PATH(jemalloc, "${PHP_JEMALLOC_DIR}/${PHP_LIBDIR}")
        PHP_ADD_LIBRARY(jemalloc, 1, SWOOLE_SHARED_LIBADD)
    fi

    PHP_ADD_LIBRARY(pthread, 1, SWOOLE_SHARED_LIBADD)

    if test "$PHP_HTTP2" = "yes" || test "$PHP_NGHTTP2_DIR" != "no"; then
	    if test "$PHP_NGHTTP2_DIR" != "no"; then
	        PHP_ADD_INCLUDE("${PHP_NGHTTP2_DIR}/include")
	        PHP_ADD_LIBRARY_WITH_PATH(nghttp2, "${PHP_NGHTTP2_DIR}/${PHP_LIBDIR}")
	    fi
        AC_DEFINE(SW_USE_HTTP2, 1, [enable HTTP2 support])
        PHP_ADD_LIBRARY(nghttp2, 1, SWOOLE_SHARED_LIBADD)
    fi

    if test "$PHP_MYSQLND" = "yes"; then
        PHP_ADD_EXTENSION_DEP(mysqli, mysqlnd)
        AC_DEFINE(SW_USE_MYSQLND, 1, [use mysqlnd])
    fi

    if test "$PHP_COROUTINE_POSTGRESQL" = "yes"; then
        if test "$PHP_LIBPQ" != "no" || test "$PHP_LIBPQ_DIR" != "no"; then
            if test "$PHP_LIBPQ_DIR" != "no"; then
                AC_DEFINE(HAVE_LIBPQ, 1, [have libpq])
                AC_MSG_RESULT(libpq include success)
                PHP_ADD_INCLUDE("${PHP_LIBPQ_DIR}/include")
                PHP_ADD_LIBRARY_WITH_PATH(pq, "${PHP_LIBPQ_DIR}/${PHP_LIBDIR}")
                PGSQL_INCLUDE=$PHP_LIBPQ_DIR/include
            else
                PGSQL_SEARCH_PATHS="/usr /usr/local /usr/local/pgsql"
                for i in $PGSQL_SEARCH_PATHS; do
                    for j in include include/pgsql include/postgres include/postgresql ""; do
                        if test -r "$i/$j/libpq-fe.h"; then
                            PGSQL_INC_BASE=$i
                            PGSQL_INCLUDE=$i/$j
                            AC_MSG_RESULT(libpq-fe.h found in PGSQL_INCLUDE)
                            PHP_ADD_INCLUDE("${PGSQL_INCLUDE}")
                        fi
                    done
                done
            fi
            AC_DEFINE(SW_USE_POSTGRESQL, 1, [enable coroutine-postgresql support])
            PHP_ADD_LIBRARY(pq, 1, SWOOLE_SHARED_LIBADD)
        fi
        if test -z "$PGSQL_INCLUDE"; then
           AC_MSG_ERROR(Cannot find libpq-fe.h. Please confirm the libpq or specify correct PostgreSQL(libpq) installation path)
        fi
    fi

    swoole_source_file=" \
        src/core/array.c \
        src/core/base.c \
        src/core/channel.c \
        src/core/error.cc \
        src/core/hashmap.c \
        src/core/heap.c \
        src/core/list.c \
        src/core/log.c \
        src/core/rbtree.c \
        src/core/ring_queue.c \
        src/core/socket.c \
        src/core/string.c \
        src/coroutine/base.cc \
        src/coroutine/boost.cc \
        src/coroutine/channel.cc \
        src/coroutine/context.cc \
        src/coroutine/hook.cc \
        src/coroutine/socket.cc \
        src/coroutine/ucontext.cc \
        src/lock/atomic.c \
        src/lock/cond.c \
        src/lock/file_lock.c \
        src/lock/mutex.c \
        src/lock/rw_lock.c \
        src/lock/semaphore.c \
        src/lock/spin_lock.c \
        src/memory/buffer.c \
        src/memory/fixed_pool.c \
        src/memory/global_memory.c \
        src/memory/malloc.c \
        src/memory/ring_buffer.c \
        src/memory/shared_memory.c \
        src/memory/table.c \
        src/network/async_thread.cc \
        src/network/cares.cc \
        src/network/client.c \
        src/network/connection.c \
        src/network/dns.c \
        src/network/process_pool.c \
        src/network/stream.c \
        src/network/thread_pool.c \
        src/network/timer.c \
        src/os/base.c \
        src/os/msg_queue.c \
        src/os/sendfile.c \
        src/os/signal.c \
        src/os/timer.c \
        src/os/wait.cc \
        src/pipe/base.c \
        src/pipe/eventfd.c \
        src/pipe/unix_socket.c \
        src/protocol/base.c \
        src/protocol/base64.c \
        src/protocol/http.c \
        src/protocol/http2.c \
        src/protocol/mime_types.cc \
        src/protocol/mqtt.c \
        src/protocol/redis.c \
        src/protocol/sha1.c \
        src/protocol/socks5.c \
        src/protocol/ssl.c \
        src/protocol/websocket.c \
        src/reactor/base.c \
        src/reactor/defer_task.cc \
        src/reactor/epoll.c \
        src/reactor/kqueue.c \
        src/reactor/poll.c \
        src/reactor/select.c \
        src/server/base.c \
        src/server/manager.c \
        src/server/master.cc \
        src/server/port.c \
        src/server/process.c \
        src/server/reactor_process.cc \
        src/server/reactor_thread.c \
        src/server/task_worker.c \
        src/server/worker.cc \
        src/wrapper/client.cc \
        src/wrapper/server.cc \
        src/wrapper/timer.cc \
        swoole.c \
        swoole_async.cc \
        swoole_atomic.c \
        swoole_buffer.c \
        swoole_channel.c \
        swoole_channel_coro.cc \
        swoole_client.cc \
        swoole_client_coro.cc \
        swoole_coroutine.cc \
        swoole_coroutine_util.cc \
        swoole_event.c \
        swoole_http_client.c \
        swoole_http_client_coro.cc \
        swoole_http_server.cc \
        swoole_http_v2_client_coro.cc \
        swoole_http_v2_server.cc \
        swoole_lock.c \
        swoole_memory_pool.c \
        swoole_mmap.c \
        swoole_msgqueue.c \
        swoole_mysql.c \
        swoole_mysql_coro.cc \
        swoole_postgresql_coro.cc \
        swoole_process.cc \
        swoole_process_pool.cc \
        swoole_redis.c \
        swoole_redis_coro.cc \
        swoole_redis_server.cc \
        swoole_ringqueue.c \
        swoole_runtime.cc \
        swoole_serialize.c \
        swoole_server.cc \
        swoole_server_port.cc \
        swoole_socket_coro.cc \
        swoole_table.c \
        swoole_timer.cc \
        swoole_trace.c \
        swoole_websocket_server.cc"

    swoole_source_file="$swoole_source_file \
    thirdparty/swoole_http_parser.c \
    thirdparty/multipart_parser.c"

    if test "$PHP_PICOHTTPPARSER" = "yes"; then
        AC_DEFINE(SW_USE_PICOHTTPPARSER, 1, [enable picohttpparser support])
        swoole_source_file="$swoole_source_file thirdparty/picohttpparser/picohttpparser.c"
    fi

    swoole_source_file="$swoole_source_file \
        thirdparty/hiredis/async.c \
        thirdparty/hiredis/hiredis.c \
        thirdparty/hiredis/net.c \
        thirdparty/hiredis/read.c \
        thirdparty/hiredis/sds.c"

    SW_NO_USE_ASM_CONTEXT="no"
    SW_ASM_DIR="thirdparty/boost/asm/"

    AS_CASE([$host_cpu],
      [x86_64*], [SW_CPU="x86_64"],
      [x86*], [SW_CPU="x86"],
      [arm*], [SW_CPU="arm"],
      [arm64*], [SW_CPU="arm64"],
      [
        SW_NO_USE_ASM_CONTEXT="yes"
        AC_DEFINE([SW_NO_USE_ASM_CONTEXT], 1, [use boost asm context?])
      ]
    )

    if test "$SW_OS" = "MAC"; then
        if test "$SW_CPU" = "arm"; then
            SW_CONTEXT_ASM_FILE="arm_aapcs_macho_gas.S"
        elif test "$SW_CPU" = "arm64"; then
            SW_CONTEXT_ASM_FILE="arm64_aapcs_macho_gas.S"
        else
            SW_CONTEXT_ASM_FILE="combined_sysv_macho_gas.S"
        fi
    elif test "$SW_CPU" = "x86_64"; then
        if test "$SW_OS" = "LINUX"; then
            SW_CONTEXT_ASM_FILE="x86_64_sysv_elf_gas.S"
        else
            SW_NO_USE_ASM_CONTEXT="yes"
            AC_DEFINE([SW_NO_USE_ASM_CONTEXT], 1, [use boost asm context?])
        fi
    elif test "$SW_CPU" = "x86"; then
        if test "$SW_OS" = "LINUX"; then
            SW_CONTEXT_ASM_FILE="i386_sysv_elf_gas.S"
        else
            SW_NO_USE_ASM_CONTEXT="yes"
            AC_DEFINE([SW_NO_USE_ASM_CONTEXT], 1, [use boost asm context?])
        fi
    elif test "$SW_CPU" = "arm"; then
        if test "$SW_OS" = "LINUX"; then
            SW_CONTEXT_ASM_FILE="arm_aapcs_elf_gas.S"
        else
            SW_NO_USE_ASM_CONTEXT="yes"
            AC_DEFINE([SW_NO_USE_ASM_CONTEXT], 1, [use boost asm context?])
        fi
    elif test "$SW_CPU" = "arm64"; then
        if test "$SW_OS" = "LINUX"; then
            SW_CONTEXT_ASM_FILE="arm64_aapcs_elf_gas.S"
        else
            SW_NO_USE_ASM_CONTEXT="yes"
            AC_DEFINE([SW_NO_USE_ASM_CONTEXT], 1, [use boost asm context?])
        fi
    elif test "$SW_CPU" = "mips32"; then
        if test "$SW_OS" = "LINUX"; then
           SW_CONTEXT_ASM_FILE="mips32_o32_elf_gas.S"
        else
            SW_NO_USE_ASM_CONTEXT="yes"
            AC_DEFINE([SW_NO_USE_ASM_CONTEXT], 1, [use boost asm context?])
        fi
    fi

    if test "$SW_NO_USE_ASM_CONTEXT" = "no"; then
        swoole_source_file="$swoole_source_file \
            ${SW_ASM_DIR}make_${SW_CONTEXT_ASM_FILE} \
            ${SW_ASM_DIR}jump_${SW_CONTEXT_ASM_FILE} "
    elif test "$SW_HAVE_BOOST_CONTEXT" = "yes"; then
         LDFLAGS="$LDFLAGS -lboost_context"
    fi

    if test "$PHP_CARES" != "no" || test "$PHP_CARES_DIR" != "no"; then
        if test "$PHP_CARES_DIR" != "no"; then
            PHP_ADD_LIBRARY_WITH_PATH(cares, "$PHP_CARES_DIR/lib")
            PHP_ADD_INCLUDE([$PHP_CARES_DIR])
        fi

        AC_DEFINE(SW_USE_CARES, 1, [enable c-ares support])
        PHP_ADD_LIBRARY(cares, 1, SWOOLE_SHARED_LIBADD)
    fi

    PHP_NEW_EXTENSION(swoole, $swoole_source_file, $ext_shared,,, cxx)

    PHP_ADD_INCLUDE([$ext_srcdir])
    PHP_ADD_INCLUDE([$ext_srcdir/include])

    PHP_ADD_INCLUDE([$ext_srcdir/thirdparty/hiredis])

    PHP_INSTALL_HEADERS([ext/swoole], [*.h config.h include/*.h])

    PHP_REQUIRE_CXX()
    
    CXXFLAGS="$CXXFLAGS -Wall -Wno-unused-function -Wno-deprecated -Wno-deprecated-declarations -std=c++11"

    if test "$PHP_PICOHTTPPARSER" = "yes"; then
        PHP_ADD_INCLUDE([$ext_srcdir/thirdparty/picohttpparser])
        PHP_ADD_BUILD_DIR($ext_builddir/thirdparty/picohttpparser)
    fi

    PHP_ADD_BUILD_DIR($ext_builddir/src/core)
    PHP_ADD_BUILD_DIR($ext_builddir/src/memory)
    PHP_ADD_BUILD_DIR($ext_builddir/src/reactor)
    PHP_ADD_BUILD_DIR($ext_builddir/src/pipe)
    PHP_ADD_BUILD_DIR($ext_builddir/src/lock)
    PHP_ADD_BUILD_DIR($ext_builddir/src/os)
    PHP_ADD_BUILD_DIR($ext_builddir/src/network)
    PHP_ADD_BUILD_DIR($ext_builddir/src/server)
    PHP_ADD_BUILD_DIR($ext_builddir/src/protocol)
    PHP_ADD_BUILD_DIR($ext_builddir/src/coroutine)
    PHP_ADD_BUILD_DIR($ext_builddir/src/wrapper)
    PHP_ADD_BUILD_DIR($ext_builddir/thirdparty/hiredis)
    PHP_ADD_BUILD_DIR($ext_builddir/thirdparty/boost)
    PHP_ADD_BUILD_DIR($ext_builddir/thirdparty/boost/asm)
fi
