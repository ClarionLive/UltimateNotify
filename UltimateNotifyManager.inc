
RegisteredThreadsQueueType  QUEUE,TYPE
ParentThread                    LONG
ThreadName                      STRING(100)
ThreadNumber                    LONG
                            END

NotifyGroupsQueueType       QUEUE,TYPE
GroupName                       STRING(100)
ThreadName                      STRING(100)
ThreadNumber                    LONG
                            END

NotifyParmsQueueType        QUEUE,TYPE
ID                              LONG
Parameter                       &STRING
                            END

!--------------------------------------------------------------------------------
UltimateNotifyManager       CLASS,TYPE,MODULE('UltimateNotifyManager.CLW'),LINK('UltimateNotifyManager.CLW')   !,_ABCLinkMode_),DLL(_ABCDllMode_)
!
!Properties
!----------

qThreads                        &RegisteredThreadsQueueType

qNotifyParms                    &NotifyParmsQueueType

qNotifyGroups                   &NotifyGroupsQueueType

CriticalSection                 &ICriticalSection

NotifyID                        LONG
!
!Methods
!-------


Construct                       PROCEDURE()
Destruct                        PROCEDURE()

AddProcedure                    PROCEDURE(STRING pProcedureName,LONG pParentThread=0),Virtual
DeleteProcedure                 PROCEDURE(STRING pProcedureName,LONG pParentThread=0),Virtual

AddNotifyGroup                  PROCEDURE(STRING pNotifyGroup,STRING pProcedure,LONG pThread)

NotifyThread                    PROCEDURE(STRING pParameters,LONG pThread,LONG pNcode = 1),Virtual
NotifyProcedure                 PROCEDURE(STRING pProcedure,STRING pParameters,LONG pNcode = 1),Virtual
NotifyProcedureThread           PROCEDURE(STRING pProcedure,LONG pThread,STRING pParameters,LONG pNcode = 1),Virtual
NotifyChild                     PROCEDURE(STRING pProcedure,STRING pParameters,LONG pNcode = 1),Virtual
NotifyParent                    PROCEDURE(STRING pParameters,LONG pNcode = 1),Virtual
NotifyGroup                     PROCEDURE(STRING pNotifyGroup,STRING pParameters,LONG pNcode = 1),Virtual

AddNotifyParms                  PROCEDURE(STRING pParameters),BYTE
GetNotifyParm                   PROCEDURE(LONG pID),STRING,Virtual

FindParentEntry                 PROCEDURE(STRING pProcedure),BYTE,Virtual
FindChildEntry                  PROCEDURE(),BYTE,Virtual


Wait                            Procedure(Long pId),Virtual
Release                         Procedure(Long pId),Virtual
Trace                           Procedure(string pStr),Virtual
                            END


