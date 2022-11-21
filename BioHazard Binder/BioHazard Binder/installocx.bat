@echo
Copy commandbars.ocx "C:\Windows\system32\commandbars.ocx"
Copy controls.ocx "C:\Windows\system32\controls.ocx"
regsvr32 "C:\Windows\system32\controls.ocx"
regsvr32 "C:\Windows\system32\commandbars.ocx"