# Copyright (c) 2014-2017, Ruslan Baratov
# All rights reserved.

if(DEFINED POLLY_FLAGS_LTO_CMAKE_)
  return()
else()
  set(POLLY_FLAGS_LTO_CMAKE_ 1)
endif()

include(polly_add_cache_flag)
include(polly_fatal_error)

string(COMPARE EQUAL "${ANDROID_NDK_VERSION}" "" _not_android)

# TODO: test other platfroms, CMAKE_CXX_FLAGS_INIT should work for all
if(_not_android)
  polly_add_cache_flag(CMAKE_CXX_FLAGS "-flto")
  polly_add_cache_flag(CMAKE_C_FLAGS "-flto")
else()
  polly_add_cache_flag(CMAKE_CXX_FLAGS_INIT "-flto")
  polly_add_cache_flag(CMAKE_C_FLAGS_INIT "-flto")

  if(CMAKE_HOST_WIN32)
    set(_host_tag "windows")
  elseif(CMAKE_HOST_APPLE)
    set(_host_tag "darwin")
  else()
    set(_host_tag "linux")
  endif()

  # Fix for "BFD: ... : plugin needed to handle lto object" {
  set(
      CMAKE_AR
      "${ANDROID_NDK}/toolchains/arm-linux-androideabi-4.9/prebuilt/${_host_tag}-x86_64/bin/arm-linux-androideabi-gcc-ar"
      CACHE
      PATH
      ""
      FORCE
  )
  # TODO: alternative 'set(CMAKE_AR "${CMAKE_AR} --plugin=/.../liblto_plugin.so")'?

  if(EXISTS "/bin/true")
    set(_true_exe "/bin/true")
  elseif(EXISTS "/usr/bin/true")
    set(_true_exe "/usr/bin/true")
  else()
    polly_fatal_error("'true' executable not found")
  endif()

  set(CMAKE_RANLIB "${_true_exe}" CACHE PATH "" FORCE)
  # }


  if(0) # TODO: do we need it?
    set(CMAKE_C_ARCHIVE_CREATE "${CMAKE_AR} qcs <TARGET> <LINK_FLAGS> <OBJECTS>")
    set(CMAKE_CXX_ARCHIVE_CREATE "${CMAKE_AR} qcs <TARGET> <LINK_FLAGS> <OBJECTS>")
  endif()

  # SECTION A
  if(0) # TODO: do we need it?
    polly_add_cache_flag(CMAKE_EXE_LINKER_FLAGS_INIT "-fuse-ld=gold")
    polly_add_cache_flag(CMAKE_SHARED_LINKER_FLAGS_INIT "-fuse-ld=gold")

    polly_add_cache_flag(CMAKE_EXE_LINKER_FLAGS_INIT "-flto")
    polly_add_cache_flag(CMAKE_SHARED_LINKER_FLAGS_INIT "-flto")
  endif()

  # SECTION B
  if(0) # TODO: do we need it?
    polly_add_cache_flag(CMAKE_EXE_LINKER_FLAGS_INIT "-Wl,-flto")
    polly_add_cache_flag(CMAKE_SHARED_LINKER_FLAGS_INIT "-Wl,-flto")
    polly_add_cache_flag(CMAKE_EXE_LINKER_FLAGS_INIT "-Wl,-fuse-ld=gold")
    polly_add_cache_flag(CMAKE_SHARED_LINKER_FLAGS_INIT "-Wl,-fuse-ld=gold")
  endif()
endif()

list(APPEND HUNTER_TOOLCHAIN_UNDETECTABLE_ID "lto")
