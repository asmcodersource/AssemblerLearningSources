format PE GUI 4.0
include 'win32ax.inc'

proc strlen str0
  push ebx
  mov ebx,[str0]
  xor eax,eax
  dec ebx
  .pStart:
  inc eax
  inc ebx
  cmp byte [ebx],0
  jnz .pStart
  pop ebx
  ret
endp

  stack_dec:
    xor edx,edx
    div ecx
    add edx,'0'
    push edx
    test eax,eax
    jz .purge_dec
    call stack_dec
    .purge_dec:
    pop dword[edi]
    inc edi
    ret

proc intToString integer, charPtr
  mov eax,[integer]
  mov edi,[charPtr]
  mov ecx,10
  call stack_dec
  ret
endp


proc putLine str0
  local size:DWORD
  push eax
  stdcall strlen,[str0]
  dec eax
  mov [size],eax
  invoke WriteFile, [fileHandle], [str0], [size], 0, 0
  invoke WriteConsoleA,[handle],[str0],[size],0,0
  pop eax
  ret
endp


proc putDate
  xor eax, eax
  mov ax, [systemTime.wYear]
  stdcall intToString, eax, charBuffer
  stdcall putLine, charBuffer
  mov [symbol.wrapped_symbol], '-'
  stdcall putLine, symbol
  xor eax, eax
  mov ax, [systemTime.wMonth]
  stdcall intToString, eax, charBuffer
  stdcall putLine, charBuffer
  mov [symbol.wrapped_symbol], '-'
  stdcall putLine, symbol
  xor eax, eax
  mov ax, [systemTime.wDay]
  stdcall intToString, eax, charBuffer
  stdcall putLine, charBuffer
  ret
endp

proc putTime
  xor eax, eax
  mov ax, [systemTime.wHour]
  stdcall intToString, eax, charBuffer
  stdcall putLine, charBuffer
  mov [symbol.wrapped_symbol], ':'
  stdcall putLine, symbol
  mov ax, [systemTime.wSecond]
  stdcall intToString, eax, charBuffer
  stdcall putLine, charBuffer
  mov [symbol.wrapped_symbol], ':'
  stdcall putLine, symbol
   mov ax, [systemTime.wMilliseconds]
  stdcall intToString, eax, charBuffer
  stdcall putLine, charBuffer
  mov [symbol.wrapped_symbol], 0
  stdcall putLine, symbol
  ret
endp

proc putProcessName
  stdcall putLine, programMsg
  invoke GetModuleFileNameA, NULL, charBuffer, 1024
  stdcall putLine, charBuffer
  mov [symbol.wrapped_symbol], ' '
  stdcall putLine, symbol
  mov eax, [process.id]
  stdcall intToString, eax, charBuffer
  stdcall putLine, charBuffer
  stdcall putLine, newLine
  ret
endp

proc putModuleDescription  moduleHandle
  push esi
  stdcall putLine, module.filePathMsg
  stdcall putLine, newLine
  invoke GetModuleFileNameA, [moduleHandle], charBuffer, 1024
  stdcall putLine, charBuffer
  stdcall putLine, newLine
  stdcall putLine, module.informationMsg
  stdcall putLine, newLine
  invoke GetModuleInformation, [process.handle], [moduleHandle],  moduleInfo, 12
  stdcall putLine, module.lpBaseOfDllMsg
  stdcall intToString, [moduleInfo.lpBaseOfDll], charBuffer
  stdcall putLine, charBuffer
  stdcall putLine, newLine
  stdcall putLine, module.sizeOfImageMsg
  stdcall intToString, [moduleInfo.sizeOfImage], charBuffer
  stdcall putLine, charBuffer
  stdcall putLine, newLine
  stdcall putLine, module.entryPointMsg
  stdcall intToString, [moduleInfo.entryPoint], charBuffer
  stdcall putLine, charBuffer
  stdcall putLine, newLine
  stdcall putLine, module.separator
  pop esi
  ret
endp

proc putModulesDescriptions
   stdcall putLine, module.msg
   stdcall putLine, module.separator
   invoke EnumProcessModules, [process.handle], modules, 4096, NULL
   xor esi, esi
   .cycle:
     mov eax, [modules+esi]
     test eax, eax
     jz .e
     stdcall putModuleDescription, eax
     add esi, 4
     jmp .cycle
   .e:
   ret
endp

start:
  invoke AllocConsole
  invoke CreateFileA, filePath, GENERIC_WRITE, 0, NULL, OPEN_ALWAYS, 0, NULL
  mov [fileHandle], eax
  invoke SetFilePointer, [fileHandle], 0, NULL, FILE_END
  invoke GetStdHandle, STD_OUTPUT_HANDLE
  mov [handle], eax
  invoke GetCurrentProcess
  mov [process.handle], eax
  invoke GetCurrentProcessId
  mov [process.id], eax
  invoke GetCurrentProcess
  mov [process.handle], eax
  invoke GetLocalTime, systemTime
  stdcall putLine, firstMsg
  stdcall putLine, dateMsg
  stdcall putDate
  stdcall putLine, timeMsg
  stdcall putTime
  stdcall putLine, newLine
  stdcall putProcessName
  stdcall putLine, newLine

  stdcall putModulesDescriptions
  invoke CloseHandle, fileHandle
  jmp $
.end start


symbol:
   .wrapped_symbol db 0
   .terminator db 0
newLine db 10,0
firstMsg db '----------------------------------------------------------------------------------', 10,0
programMsg db 'Executable name: ',0
dateMsg db 'Date:',0
timeMsg db ', time:',0
processIdMsg db 'Current process id: ',0
charBuffer db 1024 dup(?)

module:
  .msg db 'Modules list:',10,0
  .titleMsg db 'Module id:',0
  .filePathMsg db 'Module file path:',0
  .informationMsg db 'Module information:',0
  .lpBaseOfDllMsg db 'The load address of the module:',0
  .sizeOfImageMsg db 'The size of the linear space that the module occupies, in bytes:',0
  .entryPointMsg  db 'The entry point of the module:',0

  .separator db '__________________________________________________________________________________',10,0
process:
  .id dd 0
  .handle dd 0

systemTime SYSTEMTIME
moduleInfo:
  .lpBaseOfDll dd 0
  .sizeOfImage dd 0
  .entryPoint  dd 0

modules dd 1024 dup(0)

filePath db 'dllinfo.txt',0
fileHandle dd 0
handle dd 0
