      SUBROUTINE SUG_TTBHU(P1,ANS)
C  
C FUNCTION GENERATED BY MADGRAPH
C RETURNS AMPLITUDE SQUARED SUMMED/AVG OVER COLORS
C AND HELICITIES
C FOR THE POINT IN PHASE SPACE P(0:3,NEXTERNAL)
C  
C FOR PROCESS : u g -> t t~ h u  
C  
C Crossing   1 is u g -> t t~ h u  
      IMPLICIT NONE
C  
C CONSTANTS
C  
      INTEGER    NEXTERNAL,   NCOMB,     NCROSS         
      PARAMETER (NEXTERNAL=6, NCOMB= 32, NCROSS=  1)
      INTEGER    THEL
      PARAMETER (THEL=NCOMB*NCROSS)
C  
C ARGUMENTS 
C  
      REAL*8 P1(0:3,NEXTERNAL),ANS(NCROSS)
C  
C LOCAL VARIABLES 
C  
      INTEGER NHEL(NEXTERNAL,NCOMB),NTRY
      REAL*8 T, P(0:3,NEXTERNAL)
      REAL*8 UG_TTBHU
      INTEGER IHEL,IDEN(NCROSS),IC(NEXTERNAL,NCROSS)
      INTEGER IPROC,JC(NEXTERNAL)
      LOGICAL GOODHEL(NCOMB,NCROSS)
      DATA GOODHEL/THEL*.FALSE./
      DATA NTRY/0/
      DATA (NHEL(IHEL,  1),IHEL=1,6) / -1, -1, -1, -1, -1, -1/
      DATA (NHEL(IHEL,  2),IHEL=1,6) / -1, -1, -1, -1, -1,  1/
      DATA (NHEL(IHEL,  3),IHEL=1,6) / -1, -1, -1,  1, -1, -1/
      DATA (NHEL(IHEL,  4),IHEL=1,6) / -1, -1, -1,  1, -1,  1/
      DATA (NHEL(IHEL,  5),IHEL=1,6) / -1, -1,  1, -1, -1, -1/
      DATA (NHEL(IHEL,  6),IHEL=1,6) / -1, -1,  1, -1, -1,  1/
      DATA (NHEL(IHEL,  7),IHEL=1,6) / -1, -1,  1,  1, -1, -1/
      DATA (NHEL(IHEL,  8),IHEL=1,6) / -1, -1,  1,  1, -1,  1/
      DATA (NHEL(IHEL,  9),IHEL=1,6) / -1,  1, -1, -1, -1, -1/
      DATA (NHEL(IHEL, 10),IHEL=1,6) / -1,  1, -1, -1, -1,  1/
      DATA (NHEL(IHEL, 11),IHEL=1,6) / -1,  1, -1,  1, -1, -1/
      DATA (NHEL(IHEL, 12),IHEL=1,6) / -1,  1, -1,  1, -1,  1/
      DATA (NHEL(IHEL, 13),IHEL=1,6) / -1,  1,  1, -1, -1, -1/
      DATA (NHEL(IHEL, 14),IHEL=1,6) / -1,  1,  1, -1, -1,  1/
      DATA (NHEL(IHEL, 15),IHEL=1,6) / -1,  1,  1,  1, -1, -1/
      DATA (NHEL(IHEL, 16),IHEL=1,6) / -1,  1,  1,  1, -1,  1/
      DATA (NHEL(IHEL, 17),IHEL=1,6) /  1, -1, -1, -1, -1, -1/
      DATA (NHEL(IHEL, 18),IHEL=1,6) /  1, -1, -1, -1, -1,  1/
      DATA (NHEL(IHEL, 19),IHEL=1,6) /  1, -1, -1,  1, -1, -1/
      DATA (NHEL(IHEL, 20),IHEL=1,6) /  1, -1, -1,  1, -1,  1/
      DATA (NHEL(IHEL, 21),IHEL=1,6) /  1, -1,  1, -1, -1, -1/
      DATA (NHEL(IHEL, 22),IHEL=1,6) /  1, -1,  1, -1, -1,  1/
      DATA (NHEL(IHEL, 23),IHEL=1,6) /  1, -1,  1,  1, -1, -1/
      DATA (NHEL(IHEL, 24),IHEL=1,6) /  1, -1,  1,  1, -1,  1/
      DATA (NHEL(IHEL, 25),IHEL=1,6) /  1,  1, -1, -1, -1, -1/
      DATA (NHEL(IHEL, 26),IHEL=1,6) /  1,  1, -1, -1, -1,  1/
      DATA (NHEL(IHEL, 27),IHEL=1,6) /  1,  1, -1,  1, -1, -1/
      DATA (NHEL(IHEL, 28),IHEL=1,6) /  1,  1, -1,  1, -1,  1/
      DATA (NHEL(IHEL, 29),IHEL=1,6) /  1,  1,  1, -1, -1, -1/
      DATA (NHEL(IHEL, 30),IHEL=1,6) /  1,  1,  1, -1, -1,  1/
      DATA (NHEL(IHEL, 31),IHEL=1,6) /  1,  1,  1,  1, -1, -1/
      DATA (NHEL(IHEL, 32),IHEL=1,6) /  1,  1,  1,  1, -1,  1/
      DATA (  IC(IHEL,  1),IHEL=1,6) /  1,  2,  3,  4,  5,  6/
      DATA (IDEN(IHEL),IHEL=  1,  1) /  96/
C ----------
C BEGIN CODE
C ----------
      NTRY=NTRY+1
      DO IPROC=1,NCROSS
      CALL SWITCHMOM(P1,P,IC(1,IPROC),JC,NEXTERNAL)
      DO IHEL=1,NEXTERNAL
         JC(IHEL) = +1
      ENDDO
      ANS(IPROC) = 0D0
      DO IHEL=1,NCOMB
          IF (GOODHEL(IHEL,IPROC) .OR. NTRY .LT. 2) THEN
             T=UG_TTBHU(P ,NHEL(1,IHEL),JC(1))            
             ANS(IPROC)=ANS(IPROC)+T
              IF (T .GT. 0D0 .AND. .NOT. GOODHEL(IHEL,IPROC)) THEN
                  GOODHEL(IHEL,IPROC)=.TRUE.
C             WRITE(*,*) IHEL,T
              ENDIF
          ENDIF
      ENDDO
      ANS(IPROC)=ANS(IPROC)/DBLE(IDEN(IPROC))
      ENDDO
      END
       
       
      REAL*8 FUNCTION UG_TTBHU(P,NHEL,IC)
C  
C FUNCTION GENERATED BY MADGRAPH
C RETURNS AMPLITUDE SQUARED SUMMED/AVG OVER COLORS
C FOR THE POINT WITH EXTERNAL LINES W(0:6,NEXTERNAL)
C  
C FOR PROCESS : u g -> t t~ h u  
C  
      IMPLICIT NONE
C  
C CONSTANTS
C  
      INTEGER    NGRAPHS,    NEIGEN,    NEXTERNAL       
      PARAMETER (NGRAPHS=  12,NEIGEN=  4,NEXTERNAL=6)   
      INTEGER    NWAVEFUNCS     , NCOLOR
      PARAMETER (NWAVEFUNCS=  20, NCOLOR=   4) 
      REAL*8     ZERO
      PARAMETER (ZERO=0D0)
C  
C ARGUMENTS 
C  
      REAL*8 P(0:3,NEXTERNAL)
      INTEGER NHEL(NEXTERNAL), IC(NEXTERNAL)
C  
C LOCAL VARIABLES 
C  
      INTEGER I,J
      COMPLEX*16 ZTEMP
      REAL*8 DENOM(NCOLOR), CF(NCOLOR,NCOLOR)
      COMPLEX*16 AMP(NGRAPHS), JAMP(NCOLOR)
      COMPLEX*16 W(6,NWAVEFUNCS)
C  
C GLOBAL VARIABLES
C  
      INCLUDE 'coupl.inc'
C  
C COLOR DATA
C  
      DATA Denom(1  )/            3/                                       
      DATA (CF(i,1  ),i=1  ,4  ) /     8,   -1,   -2,    7/                
C               T[6,4]T[3,1,2]                                             
      DATA Denom(2  )/            3/                                       
      DATA (CF(i,2  ),i=1  ,4  ) /    -1,    8,    7,   -2/                
C               T[6,4,2]T[3,1]                                             
      DATA Denom(3  )/            3/                                       
      DATA (CF(i,3  ),i=1  ,4  ) /    -2,    7,    8,   -1/                
C               T[3,1]T[6,4,2]                                             
      DATA Denom(4  )/            3/                                       
      DATA (CF(i,4  ),i=1  ,4  ) /     7,   -2,   -1,    8/                
C               T[6,4]T[3,1,2]                                             
C ----------
C BEGIN CODE
C ----------
      CALL IXXXXX(P(0,1   ),ZERO ,NHEL(1   ),+1*IC(1   ),W(1,1   ))        
      CALL VXXXXX(P(0,2   ),ZERO ,NHEL(2   ),-1*IC(2   ),W(1,2   ))        
      CALL OXXXXX(P(0,3   ),TMASS ,NHEL(3   ),+1*IC(3   ),W(1,3   ))       
      CALL IXXXXX(P(0,4   ),TMASS ,NHEL(4   ),-1*IC(4   ),W(1,4   ))       
      CALL SXXXXX(P(0,5   ),+1*IC(5   ),W(1,5   ))                         
      CALL OXXXXX(P(0,6   ),ZERO ,NHEL(6   ),+1*IC(6   ),W(1,6   ))        
      CALL FSOXXX(W(1,3   ),W(1,5   ),GHTOP ,TMASS   ,TWIDTH  ,W(1,        
     &     7   ))                                                          
      CALL JIOXXX(W(1,1   ),W(1,6   ),GG ,ZERO    ,ZERO    ,W(1,8   ))     
      CALL FVOXXX(W(1,7   ),W(1,2   ),GG ,TMASS   ,TWIDTH  ,W(1,9   ))     
      CALL IOVXXX(W(1,4   ),W(1,9   ),W(1,8   ),GG ,AMP(1   ))             
      CALL FVOXXX(W(1,3   ),W(1,2   ),GG ,TMASS   ,TWIDTH  ,W(1,10  ))     
      CALL FSIXXX(W(1,4   ),W(1,5   ),GHTOP ,TMASS   ,TWIDTH  ,W(1,        
     &     11  ))                                                          
      CALL IOVXXX(W(1,11  ),W(1,10  ),W(1,8   ),GG ,AMP(2   ))             
      CALL FSOXXX(W(1,10  ),W(1,5   ),GHTOP ,TMASS   ,TWIDTH  ,W(1,        
     &     12  ))                                                          
      CALL IOVXXX(W(1,4   ),W(1,12  ),W(1,8   ),GG ,AMP(3   ))             
      CALL FVIXXX(W(1,4   ),W(1,2   ),GG ,TMASS   ,TWIDTH  ,W(1,13  ))     
      CALL IOVXXX(W(1,13  ),W(1,7   ),W(1,8   ),GG ,AMP(4   ))             
      CALL FVOXXX(W(1,3   ),W(1,8   ),GG ,TMASS   ,TWIDTH  ,W(1,14  ))     
      CALL IOVXXX(W(1,11  ),W(1,14  ),W(1,2   ),GG ,AMP(5   ))             
      CALL FSIXXX(W(1,13  ),W(1,5   ),GHTOP ,TMASS   ,TWIDTH  ,W(1,        
     &     15  ))                                                          
      CALL IOVXXX(W(1,15  ),W(1,3   ),W(1,8   ),GG ,AMP(6   ))             
      CALL JVVXXX(W(1,8   ),W(1,2   ),G ,ZERO    ,ZERO    ,W(1,16  ))      
      CALL IOVXXX(W(1,4   ),W(1,7   ),W(1,16  ),GG ,AMP(7   ))             
      CALL FVOXXX(W(1,6   ),W(1,2   ),GG ,ZERO    ,ZERO    ,W(1,17  ))     
      CALL JIOXXX(W(1,1   ),W(1,17  ),GG ,ZERO    ,ZERO    ,W(1,18  ))     
      CALL IOVXXX(W(1,4   ),W(1,7   ),W(1,18  ),GG ,AMP(8   ))             
      CALL FVIXXX(W(1,1   ),W(1,2   ),GG ,ZERO    ,ZERO    ,W(1,19  ))     
      CALL JIOXXX(W(1,19  ),W(1,6   ),GG ,ZERO    ,ZERO    ,W(1,20  ))     
      CALL IOVXXX(W(1,4   ),W(1,7   ),W(1,20  ),GG ,AMP(9   ))             
      CALL IOVXXX(W(1,11  ),W(1,3   ),W(1,16  ),GG ,AMP(10  ))             
      CALL IOVXXX(W(1,11  ),W(1,3   ),W(1,18  ),GG ,AMP(11  ))             
      CALL IOVXXX(W(1,11  ),W(1,3   ),W(1,20  ),GG ,AMP(12  ))             
      JAMP(   1) = -AMP(   1)-AMP(   2)-AMP(   3)+AMP(   7)+AMP(  10) 
      JAMP(   2) = -AMP(   4)-AMP(   5)-AMP(   6)-AMP(   7)-AMP(  10) 
      JAMP(   3) = -AMP(   8)-AMP(  11) 
      JAMP(   4) = -AMP(   9)-AMP(  12) 
      UG_TTBHU = 0.D0 
      DO I = 1, NCOLOR
          ZTEMP = (0.D0,0.D0)
          DO J = 1, NCOLOR
              ZTEMP = ZTEMP + CF(J,I)*JAMP(J)
          ENDDO
          UG_TTBHU =UG_TTBHU+ZTEMP*DCONJG(JAMP(I))/DENOM(I)   
      ENDDO
C      CALL GAUGECHECK(JAMP,ZTEMP,EIGEN_VEC,EIGEN_VAL,NCOLOR,NEIGEN) 
      END
