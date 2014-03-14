                    MEMBER()
 
    INCLUDE('EQUATES.CLW')
    INCLUDE('UltimateNotify.INC'),ONCE

                    MAP
                    END


UltimateNotify.CONSTRUCT    PROCEDURE()

    CODE
        
        SELF.qNotifyCode         &= NEW NotifyCodeQueueType

    
UltimateNotify.DESTRUCT     PROCEDURE()

    CODE
        
        FREE(SELF.qNotifyCode)
        DISPOSE(SELF.qNotifyCode)
        
         
        

        
UltimateNotify.InitWindow PROCEDURE()

    CODE
        
        REGISTER(EVENT:Notify, ADDRESS(SELF.OnNotify), ADDRESS(SELF))

!!
!!UltimateNotify.KillWindow PROCEDURE()
!!
!!    CODE
!!        
!!        UNREGISTER(EVENT:Notify, ADDRESS(SELF.OnNotify), ADDRESS(SELF))

        
UltimateNotify.AddNotifyCode        PROCEDURE(UNSIGNED pNotifyCode)  

    CODE
        
        IF ~SELF.FindNotifyCode(pNotifyCode)
            SELF.qNotifyCode.NotifyCode = pNotifyCode
            ADD(SELF.qNotifyCode,SELF.qNotifyCode.NotifyCode)
        END
        
        
UltimateNotify.FindNotifyCode       PROCEDURE(UNSIGNED pNotifyCode)  !,BYTE

Result                                  BYTE(TRUE)

    CODE
        
        CLEAR(SELF.qNotifyCode)
        SELF.qNotifyCode.NotifyCode = pNotifyCode
        GET(SELF.qNotifyCode,SELF.qNotifyCode.NotifyCode)
        IF ERRORCODE()
            Result = FALSE
        END
            
        RETURN  Result
        
        
UltimateNotify.OnNotify     PROCEDURE()  !Byte

NotifyCode                      UNSIGNED,AUTO
NotifyThread                    SIGNED,AUTO
NotifyParameter                 LONG,AUTO

    CODE
        
!!        IF EVENT() = EVENT:Notify
        IF NOTIFICATION(NotifyCode,NotifyThread,NotifyParameter)
            IF SELF.FindNotifyCode(NotifyCode)
                SELF.HandleNotify(NotifyCode,NotifyThread,NotifyParameter)
            END
        END
        
!!        END
        
        RETURN Level:OK

        
UltimateNotify.HandleNotify PROCEDURE(UNSIGNED NotifyCode, SIGNED NotifyThread,LONG NotifyParameter)

    CODE
        
        RETURN 
        
        
        
        