                    MEMBER()
!

    INCLUDE('EQUATES.CLW')
    INCLUDE('UltimateNotifyManager.INC'),ONCE
    INCLUDE('UltimateDebug.inc'),ONCE
    Include('CWSYNCHM.INC'),Once

                    MAP
                    END

unm_ud                  UltimateDebug,THREAD

!----------------------------------------
UltimateNotifyManager.Construct     PROCEDURE()
!----------------------------------------
    CODE

        SELF.qThreads  &= NEW RegisteredThreadsQueueType
        SELF.qNotifyParms &= NEW NotifyParmsQueueType
        SELF.qNotifyGroups   &= NEW NotifyGroupsQueueType
        
        
        Self.CriticalSection     &= NewCriticalSection()
        
        RETURN


!---------------------------------------
UltimateNotifyManager.Destruct      PROCEDURE()
!---------------------------------------
    CODE

        FREE(SELF.qThreads)
        DISPOSE(SELF.qNotifyParms)
        
        FREE(SELF.qThreads)
        DISPOSE(SELF.qNotifyParms)
        
        FREE(SELF.qNotifyGroups)
        DISPOSE(SELF.qNotifyGroups)
        
        IF ~SELF.CriticalSection &= NULL
            SELF.CriticalSection.Kill()
        END
        
        RETURN



!-----------------------------------
UltimateNotifyManager.AddProcedure  PROCEDURE(STRING pProcedureName,LONG pParentThread=0)
!-----------------------------------

    CODE
        
        SELF.Wait(3)
        
        CLEAR(SELF.qThreads)
        SELF.qThreads.ParentThread = pParentThread
        SELF.qThreads.ThreadName = pProcedureName
        SELF.qThreads.ThreadNumber = THREAD()
        
        GET(SELF.qThreads,SELF.qThreads.ThreadName,SELF.qThreads.ThreadNumber)
        IF ERROR()
            ADD(SELF.qThreads,SELF.qThreads.ThreadName,SELF.qThreads.ThreadNumber)
        END
        
        SELF.Release(3)
        
        RETURN
    
        
!-----------------------------------
UltimateNotifyManager.DeleteProcedure  PROCEDURE(STRING pProcedureName,LONG pParentThread=0)
!-----------------------------------

    CODE
        
        SELF.Wait(6)
        
        SELF.qThreads.ParentThread = pParentThread
        SELF.qThreads.ThreadName = pProcedureName
        SELF.qThreads.ThreadNumber = THREAD()
        GET(SELF.qThreads,SELF.qThreads.ThreadName,SELF.qThreads.ThreadNumber)
        IF ~ERROR()
            DELETE(SELF.qThreads)
        END
        
        SELF.Release(6)

        RETURN

!-----------------------------------
UltimateNotifyManager.AddNotifyGroup        PROCEDURE(STRING pNotifyGroup,STRING pProcedure,LONG pThread)
!-----------------------------------

    CODE
        
        SELF.Wait(9)
        
        SELF.qNotifyGroups.GroupName = pNotifyGroup
        SELF.qNotifyGroups.ThreadName = pProcedure
        SELF.qNotifyGroups.ThreadNumber = THREAD()
        GET(SELF.qNotifyGroups,SELF.qNotifyGroups.GroupName,SELF.qNotifyGroups.ThreadName,SELF.qNotifyGroups.ThreadNumber)
        IF ERROR()
            ADD(SELF.qNotifyGroups)
        END
        
        SELF.Release(9)
        
        RETURN
        
!-----------------------------------
UltimateNotifyManager.NotifyThread  PROCEDURE(STRING pParameters,LONG pThread,LONG pNcode = 1)
!-----------------------------------

    CODE
        
        IF ~SELF.AddNotifyParms(pParameters)
            NOTIFY(pNcode,pThread,SELF.NotifyID)
        END
        
        RETURN


!-----------------------------------
UltimateNotifyManager.NotifyProcedure       PROCEDURE(STRING pProcedure,STRING pParameters,LONG pNcode = 1)
!-----------------------------------

qLocalThreads                                   &RegisteredThreadsQueueType
                                                
LocalCount                                      LONG

    CODE
        
        qLocalThreads &= NEW RegisteredThreadsQueueType
        
        SELF.Wait(8)
        
        LOOP LocalCount = 1 TO RECORDS(SELF.qThreads)
            GET(SELF.qThreads,LocalCount)
            IF SELF.qThreads.ThreadName = pProcedure
                qLocalThreads = SELF.qThreads
                ADD(qLocalThreads)
            END
        END
        
        SELF.Release(8)
        
        LOOP LocalCount = 1 TO RECORDS(qLocalThreads)
            GET(qLocalThreads,LocalCount)
            IF ~SELF.AddNotifyParms(pParameters)
                NOTIFY(pNcode,qLocalThreads.ThreadNumber,SELF.NotifyID)
            END    
        END
        
        FREE(qLocalThreads)
        DISPOSE(qLocalThreads)
            
        RETURN


!-----------------------------------
UltimateNotifyManager.NotifyProcedureThread PROCEDURE(STRING pProcedure,LONG pThread,STRING pParameters,LONG pNcode = 1)
!-----------------------------------
qLocalThreads       &RegisteredThreadsQueueType
                                                
LocalCount          LONG

    CODE
        
        qLocalThreads &= NEW RegisteredThreadsQueueType
        
        SELF.Wait(7)
        
        LOOP LocalCount = 1 TO RECORDS(SELF.qThreads)
            GET(SELF.qThreads,LocalCount)
            IF SELF.qThreads.ThreadName = pProcedure AND SELF.qThreads.ThreadNumber = pThread
                qLocalThreads = SELF.qThreads
                ADD(qLocalThreads)
            END
        END
        
        SELF.Release(7)
        
        LOOP LocalCount = 1 TO RECORDS(qLocalThreads)
            GET(qLocalThreads,LocalCount)
            IF ~SELF.AddNotifyParms(pParameters)
                NOTIFY(pNcode,qLocalThreads.ThreadNumber,SELF.NotifyID)
            END    
        END
        
        FREE(qLocalThreads)
        DISPOSE(qLocalThreads)
            
        RETURN
        
 
!-----------------------------------
UltimateNotifyManager.AddNotifyParms        PROCEDURE(STRING pParameters)  !,BYTE
!-----------------------------------

    CODE
        
        SELF.NotifyID += 1
        SELF.qNotifyParms.ID = SELF.NotifyID
        SELF.qNotifyParms.Parameter &= NEW STRING(LEN(pParameters))
        SELF.qNotifyParms.Parameter = pParameters
        ADD(SELF.qNotifyParms)

        RETURN ERRORCODE()

        
!-----------------------------------
UltimateNotifyManager.NotifyParent  PROCEDURE(STRING pParameters,LONG pNcode = 1)
!-----------------------------------

ThreadNumber                            LONG

    CODE
        
        
        ThreadNumber = SELF.FindChildEntry()
        IF ThreadNumber
            IF ~SELF.AddNotifyParms(pParameters)
                NOTIFY(pNcode,ThreadNumber,SELF.NotifyID)
            END
        END
        
        RETURN 

        
!-----------------------------------
UltimateNotifyManager.FindParentEntry       PROCEDURE(STRING pProcedure) !,BYTE
!-----------------------------------

Result                                          LONG

    CODE
        
        SELF.Wait(5)
        
        CLEAR(SELF.qThreads)
        SELF.qThreads.ParentThread = Thread()
        SELF.qThreads.ThreadName = pProcedure
        GET(SELF.qThreads,SELF.qThreads.ParentThread,SELF.qThreads.ThreadName)
        IF ERRORCODE()
            Result = FALSE
        ELSE
            Result = SELF.qThreads.ThreadNumber
        END
        
        SELF.Release(5)
        
        RETURN Result
     
        
!-----------------------------------
UltimateNotifyManager.NotifyChild   PROCEDURE(STRING pProcedure,STRING pParameters,LONG pNcode = 1)
!-----------------------------------

ThreadNumber                            LONG

    CODE
        
        ThreadNumber = SELF.FindParentEntry(pProcedure)
        IF ThreadNumber
            IF ~SELF.AddNotifyParms(pParameters)
                NOTIFY(pNcode,ThreadNumber,SELF.NotifyID)
            END
            
        END
        
        RETURN   
        
        
!-----------------------------------
UltimateNotifyManager.FindChildEntry        PROCEDURE() !,BYTE  
!-----------------------------------

Result                                          LONG

    CODE
        
        SELF.Wait(4)

        CLEAR(SELF.qThreads)
        SELF.qThreads.ThreadNumber = THREAD()
        GET(SELF.qThreads,SELF.qThreads.ThreadNumber)
        IF ERRORCODE()
            Result = FALSE
        ELSE
            Result = SELF.qThreads.ParentThread
        END
        
        SELF.Release(4)
        
        RETURN Result
        
        
!-----------------------------------
UltimateNotifyManager.NotifyGroup   PROCEDURE(STRING pNotifyGroup,STRING pParameters,LONG pNcode = 1)
!-----------------------------------
qLocalThreads       &NotifyGroupsQueueType
                                                
LocalCount          LONG

    CODE
        
        qLocalThreads &= NEW NotifyGroupsQueueType
        
        SELF.Wait(8)
        
        LOOP LocalCount = 1 TO RECORDS(SELF.qNotifyGroups)
            GET(SELF.qNotifyGroups,LocalCount)
            IF SELF.qNotifyGroups.GroupName = pNotifyGroup
                qLocalThreads = SELF.qNotifyGroups
                ADD(qLocalThreads)
            END
        END
        
        SELF.Release(8)
        
        LOOP LocalCount = 1 TO RECORDS(qLocalThreads)
            GET(qLocalThreads,LocalCount)
            IF ~SELF.AddNotifyParms(pParameters)
                NOTIFY(pNcode,qLocalThreads.ThreadNumber,SELF.NotifyID)
            END    
        END
        
        FREE(qLocalThreads)
        DISPOSE(qLocalThreads)
            
        RETURN
        
        
!-----------------------------------
UltimateNotifyManager.GetNotifyParm PROCEDURE(LONG pID)  !,STRING
!-----------------------------------

ReturnValue                             &STRING

    CODE
        
        SELF.Wait(1)
        CLEAR(SELF.qNotifyParms)
        SELF.qNotifyParms.ID = pID
        GET(SELF.qNotifyParms,SELF.qNotifyParms.ID)
        IF ~ERRORCODE()
            ReturnValue &= NEW STRING(SIZE(SELF.qNotifyParms.Parameter))
            ReturnValue = SELF.qNotifyParms.Parameter
            DISPOSE(SELF.qNotifyParms.Parameter)
            DELETE(SELF.qNotifyParms)
        END
        SELF.Release(1)
        
        RETURN ReturnValue
        
        
!------------------------------------------------------------------------------
UltimateNotifyManager.Wait  Procedure(Long pId)

    code
        
        SELF.Trace('wait ' & pId)
        self.CriticalSection.wait()
        
        
!------------------------------------------------------------------------------
UltimateNotifyManager.Release       Procedure(Long pId)

    code
        
        SELF.Trace('release ' & pId)
        self.CriticalSection.release()

        
!------------------------------------------------------------------------------
UltimateNotifyManager.Trace Procedure(string pStr)

szMsg                           cString(len(pStr)+10)

    code
        
        szMsg = '[dpm] ' & Clip(pStr)
        unm_ud.DebugPrefix = '!'
        unm_ud.DebugOff = False
        unm_ud.Debug(szMsg)
        
        
!------------------------------------------------------------------------------