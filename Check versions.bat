@echo off
setlocal

:input_env
echo ---------------------------------------------------
set /p "ENV=Enter Environment (e.g., sit, uat, pt): "
:: ตรวจสอบถ้าผู้ใช้ไม่ได้พิมพ์อะไรเลย ให้ถามซ้ำ
if "%ENV%"=="" (
    echo [Error] Environment cannot be empty.
    goto :input_env
)

:input_ns
echo ---------------------------------------------------
set /p "NAMESPACE=Enter Namespace (e.g., sit, sit2, uat, uat2): "
:: ตรวจสอบถ้าผู้ใช้ไม่ได้พิมพ์อะไรเลย ให้ถามซ้ำ
if "%NAMESPACE%"=="" (
    echo [Error] Namespace cannot be empty.
    goto :input_ns
)

:input_app
echo ---------------------------------------------------
set /p "APP=Enter Application Name (e.g., cardcore, frontend, sccim-irules-loyalty, ocm, infra, kube-job): "
:: ตรวจสอบถ้าผู้ใช้ไม่ได้พิมพ์อะไรเลย ให้ถามซ้ำ
if "%APP%"=="" (
    echo [Error] Application name cannot be empty.
    goto :input_app
)


:: กำหนดชื่อ Cluster และ Namespace โดยใช้ตัวแปรแทนที่ค่าเดิม
 if "%ENV%"=="uat" (
	set "CLUSTER=cdx-uat-pci-all-eks"
 ) else (
	set "CLUSTER=cdx-sit-pci-all-eks"
 )


:: switch Mobius and OCM
 if "%APP%"=="ocm" (
	set "NS=cdx-%NAMESPACE%-ocm-ms"
 ) else if "%APP%"=="infra" (
	set "NS=cdx-%NAMESPACE%-crs-infra"
 ) else if "%APP%"=="kube-job" (
	set "NS=cdx-%NAMESPACE%-crs-infra"
 ) else ( 
	set "NS=cdx-%NAMESPACE%-crs-%APP%"
 )

echo ===================================================
echo  Target Cluster  : %CLUSTER%
echo  Target Namespace: %NS%
echo ===================================================
echo.

echo [1/3] tsh kube login %CLUSTER%
tsh kube login %CLUSTER% || goto :err

echo.


if "%APP%"=="kube-job" (
    echo [2/3] tsh kubectl get job -n %NS%
	tsh kubectl get job -n %NS% || goto :err
) else (
	echo [2/3] tsh kubectl get po -n %NS%
	tsh kubectl get po -n %NS% || goto :err
)


echo.

if "%APP%"=="kube-job" (
    echo [3/3] tsh kubectl describe job -n %NS% ^| findstr "Image:"
	tsh kubectl describe pod -n %NS% | findstr /C:"Image:"
) else (
	echo [3/3] tsh kubectl describe pod -n %NS% ^| findstr "Image:"
	tsh kubectl describe pod -n %NS% | findstr /C:"Image:"
)



goto :end

:usage
echo [ERROR] Missing arguments!
echo Usage: %~nx0 [env] [namespace] [app]
echo Example: %~nx0 sit cardcore
echo Example: %~nx0 uat register
echo.
goto :end

:err
echo.
echo [ERROR] An error occurred during execution.
echo.

:end
pause