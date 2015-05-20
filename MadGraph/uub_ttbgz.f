      SUBROUTINE SUUB_TTBGZ(P1,ANS)
C  
C FUNCTION GENERATED BY MADGRAPH
C RETURNS AMPLITUDE SQUARED SUMMED/AVG OVER COLORS
C AND HELICITIES
C FOR THE POINT IN PHASE SPACE P(0:3,NEXTERNAL)
C  
C FOR PROCESS : u u~ -> t t~ g z  
C  
C Crossing   1 is u u~ -> t t~ g z  
      IMPLICIT NONE
C  
C CONSTANTS
C  
      INTEGER    NEXTERNAL,   NCOMB,     NCROSS         
      PARAMETER (NEXTERNAL=6, NCOMB= 96, NCROSS=  1)
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
      REAL*8 UUB_TTBGZ
      INTEGER IHEL,IDEN(NCROSS),IC(NEXTERNAL,NCROSS)
      INTEGER IPROC,JC(NEXTERNAL)
      LOGICAL GOODHEL(NCOMB,NCROSS)
      DATA GOODHEL/THEL*.FALSE./
      DATA NTRY/0/
      DATA (NHEL(IHEL,  1),IHEL=1,6) / -1, -1, -1, -1, -1, -1/
      DATA (NHEL(IHEL,  2),IHEL=1,6) / -1, -1, -1, -1, -1,  0/
      DATA (NHEL(IHEL,  3),IHEL=1,6) / -1, -1, -1, -1, -1,  1/
      DATA (NHEL(IHEL,  4),IHEL=1,6) / -1, -1, -1, -1,  1, -1/
      DATA (NHEL(IHEL,  5),IHEL=1,6) / -1, -1, -1, -1,  1,  0/
      DATA (NHEL(IHEL,  6),IHEL=1,6) / -1, -1, -1, -1,  1,  1/
      DATA (NHEL(IHEL,  7),IHEL=1,6) / -1, -1, -1,  1, -1, -1/
      DATA (NHEL(IHEL,  8),IHEL=1,6) / -1, -1, -1,  1, -1,  0/
      DATA (NHEL(IHEL,  9),IHEL=1,6) / -1, -1, -1,  1, -1,  1/
      DATA (NHEL(IHEL, 10),IHEL=1,6) / -1, -1, -1,  1,  1, -1/
      DATA (NHEL(IHEL, 11),IHEL=1,6) / -1, -1, -1,  1,  1,  0/
      DATA (NHEL(IHEL, 12),IHEL=1,6) / -1, -1, -1,  1,  1,  1/
      DATA (NHEL(IHEL, 13),IHEL=1,6) / -1, -1,  1, -1, -1, -1/
      DATA (NHEL(IHEL, 14),IHEL=1,6) / -1, -1,  1, -1, -1,  0/
      DATA (NHEL(IHEL, 15),IHEL=1,6) / -1, -1,  1, -1, -1,  1/
      DATA (NHEL(IHEL, 16),IHEL=1,6) / -1, -1,  1, -1,  1, -1/
      DATA (NHEL(IHEL, 17),IHEL=1,6) / -1, -1,  1, -1,  1,  0/
      DATA (NHEL(IHEL, 18),IHEL=1,6) / -1, -1,  1, -1,  1,  1/
      DATA (NHEL(IHEL, 19),IHEL=1,6) / -1, -1,  1,  1, -1, -1/
      DATA (NHEL(IHEL, 20),IHEL=1,6) / -1, -1,  1,  1, -1,  0/
      DATA (NHEL(IHEL, 21),IHEL=1,6) / -1, -1,  1,  1, -1,  1/
      DATA (NHEL(IHEL, 22),IHEL=1,6) / -1, -1,  1,  1,  1, -1/
      DATA (NHEL(IHEL, 23),IHEL=1,6) / -1, -1,  1,  1,  1,  0/
      DATA (NHEL(IHEL, 24),IHEL=1,6) / -1, -1,  1,  1,  1,  1/
      DATA (NHEL(IHEL, 25),IHEL=1,6) / -1,  1, -1, -1, -1, -1/
      DATA (NHEL(IHEL, 26),IHEL=1,6) / -1,  1, -1, -1, -1,  0/
      DATA (NHEL(IHEL, 27),IHEL=1,6) / -1,  1, -1, -1, -1,  1/
      DATA (NHEL(IHEL, 28),IHEL=1,6) / -1,  1, -1, -1,  1, -1/
      DATA (NHEL(IHEL, 29),IHEL=1,6) / -1,  1, -1, -1,  1,  0/
      DATA (NHEL(IHEL, 30),IHEL=1,6) / -1,  1, -1, -1,  1,  1/
      DATA (NHEL(IHEL, 31),IHEL=1,6) / -1,  1, -1,  1, -1, -1/
      DATA (NHEL(IHEL, 32),IHEL=1,6) / -1,  1, -1,  1, -1,  0/
      DATA (NHEL(IHEL, 33),IHEL=1,6) / -1,  1, -1,  1, -1,  1/
      DATA (NHEL(IHEL, 34),IHEL=1,6) / -1,  1, -1,  1,  1, -1/
      DATA (NHEL(IHEL, 35),IHEL=1,6) / -1,  1, -1,  1,  1,  0/
      DATA (NHEL(IHEL, 36),IHEL=1,6) / -1,  1, -1,  1,  1,  1/
      DATA (NHEL(IHEL, 37),IHEL=1,6) / -1,  1,  1, -1, -1, -1/
      DATA (NHEL(IHEL, 38),IHEL=1,6) / -1,  1,  1, -1, -1,  0/
      DATA (NHEL(IHEL, 39),IHEL=1,6) / -1,  1,  1, -1, -1,  1/
      DATA (NHEL(IHEL, 40),IHEL=1,6) / -1,  1,  1, -1,  1, -1/
      DATA (NHEL(IHEL, 41),IHEL=1,6) / -1,  1,  1, -1,  1,  0/
      DATA (NHEL(IHEL, 42),IHEL=1,6) / -1,  1,  1, -1,  1,  1/
      DATA (NHEL(IHEL, 43),IHEL=1,6) / -1,  1,  1,  1, -1, -1/
      DATA (NHEL(IHEL, 44),IHEL=1,6) / -1,  1,  1,  1, -1,  0/
      DATA (NHEL(IHEL, 45),IHEL=1,6) / -1,  1,  1,  1, -1,  1/
      DATA (NHEL(IHEL, 46),IHEL=1,6) / -1,  1,  1,  1,  1, -1/
      DATA (NHEL(IHEL, 47),IHEL=1,6) / -1,  1,  1,  1,  1,  0/
      DATA (NHEL(IHEL, 48),IHEL=1,6) / -1,  1,  1,  1,  1,  1/
      DATA (NHEL(IHEL, 49),IHEL=1,6) /  1, -1, -1, -1, -1, -1/
      DATA (NHEL(IHEL, 50),IHEL=1,6) /  1, -1, -1, -1, -1,  0/
      DATA (NHEL(IHEL, 51),IHEL=1,6) /  1, -1, -1, -1, -1,  1/
      DATA (NHEL(IHEL, 52),IHEL=1,6) /  1, -1, -1, -1,  1, -1/
      DATA (NHEL(IHEL, 53),IHEL=1,6) /  1, -1, -1, -1,  1,  0/
      DATA (NHEL(IHEL, 54),IHEL=1,6) /  1, -1, -1, -1,  1,  1/
      DATA (NHEL(IHEL, 55),IHEL=1,6) /  1, -1, -1,  1, -1, -1/
      DATA (NHEL(IHEL, 56),IHEL=1,6) /  1, -1, -1,  1, -1,  0/
      DATA (NHEL(IHEL, 57),IHEL=1,6) /  1, -1, -1,  1, -1,  1/
      DATA (NHEL(IHEL, 58),IHEL=1,6) /  1, -1, -1,  1,  1, -1/
      DATA (NHEL(IHEL, 59),IHEL=1,6) /  1, -1, -1,  1,  1,  0/
      DATA (NHEL(IHEL, 60),IHEL=1,6) /  1, -1, -1,  1,  1,  1/
      DATA (NHEL(IHEL, 61),IHEL=1,6) /  1, -1,  1, -1, -1, -1/
      DATA (NHEL(IHEL, 62),IHEL=1,6) /  1, -1,  1, -1, -1,  0/
      DATA (NHEL(IHEL, 63),IHEL=1,6) /  1, -1,  1, -1, -1,  1/
      DATA (NHEL(IHEL, 64),IHEL=1,6) /  1, -1,  1, -1,  1, -1/
      DATA (NHEL(IHEL, 65),IHEL=1,6) /  1, -1,  1, -1,  1,  0/
      DATA (NHEL(IHEL, 66),IHEL=1,6) /  1, -1,  1, -1,  1,  1/
      DATA (NHEL(IHEL, 67),IHEL=1,6) /  1, -1,  1,  1, -1, -1/
      DATA (NHEL(IHEL, 68),IHEL=1,6) /  1, -1,  1,  1, -1,  0/
      DATA (NHEL(IHEL, 69),IHEL=1,6) /  1, -1,  1,  1, -1,  1/
      DATA (NHEL(IHEL, 70),IHEL=1,6) /  1, -1,  1,  1,  1, -1/
      DATA (NHEL(IHEL, 71),IHEL=1,6) /  1, -1,  1,  1,  1,  0/
      DATA (NHEL(IHEL, 72),IHEL=1,6) /  1, -1,  1,  1,  1,  1/
      DATA (NHEL(IHEL, 73),IHEL=1,6) /  1,  1, -1, -1, -1, -1/
      DATA (NHEL(IHEL, 74),IHEL=1,6) /  1,  1, -1, -1, -1,  0/
      DATA (NHEL(IHEL, 75),IHEL=1,6) /  1,  1, -1, -1, -1,  1/
      DATA (NHEL(IHEL, 76),IHEL=1,6) /  1,  1, -1, -1,  1, -1/
      DATA (NHEL(IHEL, 77),IHEL=1,6) /  1,  1, -1, -1,  1,  0/
      DATA (NHEL(IHEL, 78),IHEL=1,6) /  1,  1, -1, -1,  1,  1/
      DATA (NHEL(IHEL, 79),IHEL=1,6) /  1,  1, -1,  1, -1, -1/
      DATA (NHEL(IHEL, 80),IHEL=1,6) /  1,  1, -1,  1, -1,  0/
      DATA (NHEL(IHEL, 81),IHEL=1,6) /  1,  1, -1,  1, -1,  1/
      DATA (NHEL(IHEL, 82),IHEL=1,6) /  1,  1, -1,  1,  1, -1/
      DATA (NHEL(IHEL, 83),IHEL=1,6) /  1,  1, -1,  1,  1,  0/
      DATA (NHEL(IHEL, 84),IHEL=1,6) /  1,  1, -1,  1,  1,  1/
      DATA (NHEL(IHEL, 85),IHEL=1,6) /  1,  1,  1, -1, -1, -1/
      DATA (NHEL(IHEL, 86),IHEL=1,6) /  1,  1,  1, -1, -1,  0/
      DATA (NHEL(IHEL, 87),IHEL=1,6) /  1,  1,  1, -1, -1,  1/
      DATA (NHEL(IHEL, 88),IHEL=1,6) /  1,  1,  1, -1,  1, -1/
      DATA (NHEL(IHEL, 89),IHEL=1,6) /  1,  1,  1, -1,  1,  0/
      DATA (NHEL(IHEL, 90),IHEL=1,6) /  1,  1,  1, -1,  1,  1/
      DATA (NHEL(IHEL, 91),IHEL=1,6) /  1,  1,  1,  1, -1, -1/
      DATA (NHEL(IHEL, 92),IHEL=1,6) /  1,  1,  1,  1, -1,  0/
      DATA (NHEL(IHEL, 93),IHEL=1,6) /  1,  1,  1,  1, -1,  1/
      DATA (NHEL(IHEL, 94),IHEL=1,6) /  1,  1,  1,  1,  1, -1/
      DATA (NHEL(IHEL, 95),IHEL=1,6) /  1,  1,  1,  1,  1,  0/
      DATA (NHEL(IHEL, 96),IHEL=1,6) /  1,  1,  1,  1,  1,  1/
      DATA (  IC(IHEL,  1),IHEL=1,6) /  1,  2,  3,  4,  5,  6/
      DATA (IDEN(IHEL),IHEL=  1,  1) /  36/
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
             T=UUB_TTBGZ(P ,NHEL(1,IHEL),JC(1))            
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
       
       
      REAL*8 FUNCTION UUB_TTBGZ(P,NHEL,IC)
C  
C FUNCTION GENERATED BY MADGRAPH
C RETURNS AMPLITUDE SQUARED SUMMED/AVG OVER COLORS
C FOR THE POINT WITH EXTERNAL LINES W(0:6,NEXTERNAL)
C  
C FOR PROCESS : u u~ -> t t~ g z  
C  
      IMPLICIT NONE
C  
C CONSTANTS
C  
      INTEGER    NGRAPHS,    NEIGEN,    NEXTERNAL       
      PARAMETER (NGRAPHS=  24,NEIGEN=  4,NEXTERNAL=6)   
      INTEGER    NWAVEFUNCS     , NCOLOR
      PARAMETER (NWAVEFUNCS=  30, NCOLOR=   4) 
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
      DATA (CF(i,1  ),i=1  ,4  ) /     8,   -1,    7,   -2/                
C               T[3,1,5]T[2,4]                                             
      DATA Denom(2  )/            3/                                       
      DATA (CF(i,2  ),i=1  ,4  ) /    -1,    8,   -2,    7/                
C               T[3,1]T[2,4,5]                                             
      DATA Denom(3  )/            3/                                       
      DATA (CF(i,3  ),i=1  ,4  ) /     7,   -2,    8,   -1/                
C               T[2,4]T[3,1,5]                                             
      DATA Denom(4  )/            3/                                       
      DATA (CF(i,4  ),i=1  ,4  ) /    -2,    7,   -1,    8/                
C               T[3,1]T[2,4,5]                                             
C ----------
C BEGIN CODE
C ----------
      CALL IXXXXX(P(0,1   ),ZERO ,NHEL(1   ),+1*IC(1   ),W(1,1   ))        
      CALL OXXXXX(P(0,2   ),ZERO ,NHEL(2   ),-1*IC(2   ),W(1,2   ))        
      CALL OXXXXX(P(0,3   ),TMASS ,NHEL(3   ),+1*IC(3   ),W(1,3   ))       
      CALL IXXXXX(P(0,4   ),TMASS ,NHEL(4   ),-1*IC(4   ),W(1,4   ))       
      CALL VXXXXX(P(0,5   ),ZERO ,NHEL(5   ),+1*IC(5   ),W(1,5   ))        
      CALL VXXXXX(P(0,6   ),ZMASS ,NHEL(6   ),+1*IC(6   ),W(1,6   ))       
      CALL JIOXXX(W(1,4   ),W(1,3   ),GG ,ZERO    ,ZERO    ,W(1,7   ))     
      CALL FVIXXX(W(1,1   ),W(1,6   ),GZU ,ZERO    ,ZERO    ,W(1,8   ))    
      CALL FVOXXX(W(1,2   ),W(1,7   ),GG ,ZERO    ,ZERO    ,W(1,9   ))     
      CALL IOVXXX(W(1,8   ),W(1,9   ),W(1,5   ),GG ,AMP(1   ))             
      CALL FVIXXX(W(1,1   ),W(1,5   ),GG ,ZERO    ,ZERO    ,W(1,10  ))     
      CALL FVOXXX(W(1,2   ),W(1,6   ),GZU ,ZERO    ,ZERO    ,W(1,11  ))    
      CALL IOVXXX(W(1,10  ),W(1,11  ),W(1,7   ),GG ,AMP(2   ))             
      CALL FVOXXX(W(1,3   ),W(1,6   ),GZU ,TMASS   ,TWIDTH  ,W(1,12  ))    
      CALL JIOXXX(W(1,10  ),W(1,2   ),GG ,ZERO    ,ZERO    ,W(1,13  ))     
      CALL IOVXXX(W(1,4   ),W(1,12  ),W(1,13  ),GG ,AMP(3   ))             
      CALL FVIXXX(W(1,4   ),W(1,6   ),GZU ,TMASS   ,TWIDTH  ,W(1,14  ))    
      CALL IOVXXX(W(1,14  ),W(1,3   ),W(1,13  ),GG ,AMP(4   ))             
      CALL FVIXXX(W(1,10  ),W(1,6   ),GZU ,ZERO    ,ZERO    ,W(1,15  ))    
      CALL IOVXXX(W(1,15  ),W(1,2   ),W(1,7   ),GG ,AMP(5   ))             
      CALL FVOXXX(W(1,2   ),W(1,5   ),GG ,ZERO    ,ZERO    ,W(1,16  ))     
      CALL IOVXXX(W(1,8   ),W(1,16  ),W(1,7   ),GG ,AMP(6   ))             
      CALL FVIXXX(W(1,1   ),W(1,7   ),GG ,ZERO    ,ZERO    ,W(1,17  ))     
      CALL IOVXXX(W(1,17  ),W(1,11  ),W(1,5   ),GG ,AMP(7   ))             
      CALL JIOXXX(W(1,1   ),W(1,16  ),GG ,ZERO    ,ZERO    ,W(1,18  ))     
      CALL IOVXXX(W(1,4   ),W(1,12  ),W(1,18  ),GG ,AMP(8   ))             
      CALL IOVXXX(W(1,14  ),W(1,3   ),W(1,18  ),GG ,AMP(9   ))             
      CALL FVOXXX(W(1,16  ),W(1,6   ),GZU ,ZERO    ,ZERO    ,W(1,19  ))    
      CALL IOVXXX(W(1,1   ),W(1,19  ),W(1,7   ),GG ,AMP(10  ))             
      CALL FVOXXX(W(1,3   ),W(1,5   ),GG ,TMASS   ,TWIDTH  ,W(1,20  ))     
      CALL JIOXXX(W(1,8   ),W(1,2   ),GG ,ZERO    ,ZERO    ,W(1,21  ))     
      CALL IOVXXX(W(1,4   ),W(1,20  ),W(1,21  ),GG ,AMP(11  ))             
      CALL JIOXXX(W(1,1   ),W(1,11  ),GG ,ZERO    ,ZERO    ,W(1,22  ))     
      CALL IOVXXX(W(1,4   ),W(1,20  ),W(1,22  ),GG ,AMP(12  ))             
      CALL JIOXXX(W(1,1   ),W(1,2   ),GG ,ZERO    ,ZERO    ,W(1,23  ))     
      CALL FVIXXX(W(1,4   ),W(1,23  ),GG ,TMASS   ,TWIDTH  ,W(1,24  ))     
      CALL FVIXXX(W(1,24  ),W(1,5   ),GG ,TMASS   ,TWIDTH  ,W(1,25  ))     
      CALL IOVXXX(W(1,25  ),W(1,3   ),W(1,6   ),GZU ,AMP(13  ))            
      CALL IOVXXX(W(1,14  ),W(1,20  ),W(1,23  ),GG ,AMP(14  ))             
      CALL IOVXXX(W(1,24  ),W(1,20  ),W(1,6   ),GZU ,AMP(15  ))            
      CALL FVIXXX(W(1,4   ),W(1,5   ),GG ,TMASS   ,TWIDTH  ,W(1,26  ))     
      CALL IOVXXX(W(1,26  ),W(1,3   ),W(1,21  ),GG ,AMP(16  ))             
      CALL IOVXXX(W(1,26  ),W(1,3   ),W(1,22  ),GG ,AMP(17  ))             
      CALL IOVXXX(W(1,26  ),W(1,12  ),W(1,23  ),GG ,AMP(18  ))             
      CALL FVOXXX(W(1,3   ),W(1,23  ),GG ,TMASS   ,TWIDTH  ,W(1,27  ))     
      CALL FVOXXX(W(1,27  ),W(1,5   ),GG ,TMASS   ,TWIDTH  ,W(1,28  ))     
      CALL IOVXXX(W(1,4   ),W(1,28  ),W(1,6   ),GZU ,AMP(19  ))            
      CALL IOVXXX(W(1,26  ),W(1,27  ),W(1,6   ),GZU ,AMP(20  ))            
      CALL JVVXXX(W(1,5   ),W(1,7   ),G ,ZERO    ,ZERO    ,W(1,29  ))      
      CALL IOVXXX(W(1,8   ),W(1,2   ),W(1,29  ),GG ,AMP(21  ))             
      CALL IOVXXX(W(1,1   ),W(1,11  ),W(1,29  ),GG ,AMP(22  ))             
      CALL JVVXXX(W(1,5   ),W(1,23  ),G ,ZERO    ,ZERO    ,W(1,30  ))      
      CALL IOVXXX(W(1,4   ),W(1,12  ),W(1,30  ),GG ,AMP(23  ))             
      CALL IOVXXX(W(1,14  ),W(1,3   ),W(1,30  ),GG ,AMP(24  ))             
      JAMP(   1) = -AMP(   1)-AMP(   2)-AMP(   3)-AMP(   4)-AMP(   5)
      JAMP(   2) = -AMP(   6)-AMP(   7)-AMP(   8)-AMP(   9)-AMP(  10)
      JAMP(   3) = -AMP(  11)-AMP(  12)-AMP(  13)-AMP(  14)-AMP(  15)
     &             +AMP(  21)+AMP(  22)-AMP(  23)-AMP(  24)
      JAMP(   4) = -AMP(  16)-AMP(  17)-AMP(  18)-AMP(  19)-AMP(  20)
     &             -AMP(  21)-AMP(  22)+AMP(  23)+AMP(  24)
      UUB_TTBGZ = 0.D0 
      DO I = 1, NCOLOR
          ZTEMP = (0.D0,0.D0)
          DO J = 1, NCOLOR
              ZTEMP = ZTEMP + CF(J,I)*JAMP(J)
          ENDDO
          UUB_TTBGZ =UUB_TTBGZ+ZTEMP*DCONJG(JAMP(I))/DENOM(I)   
      ENDDO
C      CALL GAUGECHECK(JAMP,ZTEMP,EIGEN_VEC,EIGEN_VAL,NCOLOR,NEIGEN) 
      END
