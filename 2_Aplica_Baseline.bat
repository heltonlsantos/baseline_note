@echo off

IF EXIST %systemdrive%\proteus.sdb del %systemdrive%\proteus.sdb
secedit /configure /db %systemdrive%\proteus.sdb /cfg "WKS-7-8-10-NOTEBOOK-PADRAO.inf"

Comandos_WKS.bat