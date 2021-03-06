module modIntDipoles_QGHTHTBQ
use ModTopdecay
implicit none

public:: EvalIntDipoles_QGHTHTBQ

integer, parameter,private  :: dp = selected_real_kind(15)
real(dp),parameter,private :: zero = 0.0_dp

double precision, private :: MomExt(1:4,1:14)


contains






      SUBROUTINE EvalIntDipoles_QGHTHTBQ(p,pDK,z,res)
      use modParameters
      use modMisc
      use ModIntDipoles
      implicit none
      real(dp), intent(in) :: p(4,4),pDK(1:4,1:10)
      real(dp), intent(out) :: res(1:3)
      real(dp) :: dipsoft,dipfini,dipplus,mtrsq,AP(1:3),epcorr
      real(dp) :: Tree_21,Tree_13,Tree_14,Tree_23,Tree_24,Tree_12,z
      real(dp) :: CA,CF,TR,L,Q2,tmp
      integer  :: n,emi,in1,in2
      complex(dp) :: TreeMom(1:4,1:4)

       MomExt(1:4,5:14) = pDK(1:4,1:10)

       res(1:3) = zero
       CF=4d0/3d0
       CA=3d0
       TR=0.5d0


!  tree momenta for g g -> t tb  &  q qb -> t tb
   TreeMom(1:4,1) =-dcmplx( p(1:4,3) )
   TreeMom(1:4,2) =-dcmplx( p(1:4,4) )
   TreeMom(1:4,3) = dcmplx( p(1:4,2) )
   TreeMom(1:4,4) = dcmplx( p(1:4,1) )

   Tree_12 = Tree_GG_TTb_00(TreeMom,(/0d0,0d0,m_HTop**2,m_HTop**2/))
   Tree_21 = Tree_UUb_TTb_ij(0,TreeMom,(/0d0,0d0,m_HTop**2,m_HTop**2/))

   do n=5,6   ! implementation for ii-contributions only
      if(n.eq.5) then
        dipsoft =ii_qg(zero,zero,p,3,4,z,1)
        dipfini =ii_qg(zero,zero,p,3,4,z,2)
        dipplus =ii_qg(zero,zero,p,3,4,z,3)
        emi = 1 ! mom #3 is emitting
        mtrsq = Tree_12*CF
      endif
      if(n.eq.6) then
        dipsoft =ii_gq(zero,zero,p,4,3,z,1)
        dipfini =ii_gq(zero,zero,p,4,3,z,2)
        dipplus =ii_gq(zero,zero,p,4,3,z,3)
        emi = 2 ! mom #4 is emitting
        mtrsq = Tree_21   ! TR is included in splitting functions
      endif

      if(emi.eq.1) then
        res(1) = res(1) + (dipsoft-dipplus)*mtrsq
        res(2) = res(2) + (dipfini+dipplus)*mtrsq
      endif
      if(emi.eq.2) then
        res(1) = res(1) + (dipsoft-dipplus)*mtrsq
        res(3) = res(3) + (dipfini+dipplus)*mtrsq
      endif
   enddo
   res(1:3) = alpha_sOver2Pi * res(1:3)!    removed a minus sign here

! print *,"1",res(1:3)

! !        epcorr=epinv+2d0*dlog(renscale/facscale)
       mtrsq = Tree_21
       epcorr=epinv
       AP(1)= 0d0
       AP(2)= TR*(z**2+(1d0-z)**2) * mtrsq * alpha_sOver2Pi *epcorr
       AP(3)= 0d0
       res(1) = res(1) + (AP(1)-AP(3))
       res(3) = res(3) + (AP(2)+AP(3))

       mtrsq = Tree_12
       AP(1)= 0d0
       AP(2)= CF * (1d0+(1d0-z)**2)/z * mtrsq * alpha_sOver2Pi *epcorr
       AP(3)= 0d0
       res(1) = res(1) + (AP(1)-AP(3))
       res(2) = res(2) + (AP(2)+AP(3)) 

! print *,"2",res(1:3)
! pause

  RETURN
  END SUBROUTINE













      FUNCTION Tree_UUb_TTb_ij(icorr,MomTd,Mass2Td) Result(SqAmp)
      use modProcess
      use modParameters
      use modMyRecurrence
      use modKinematics
      use ModExoticDecay
      implicit none
      double precision Split_A,Split_B,Split_V(0:3)
      double complex SqAmp,Amp(1,0:1),Res(0:3)
      integer col,colP,iHel,icorr,ngl,A0barHel,A0Hel,SecHel
      double complex,target :: MomTd(0:3,1:4)
      double precision,target :: Mass2Td(1:4),MassTd(1:4)
      double complex, target :: PolV(0:3,0:1,1:4)
      double precision :: PSWgt2,PSWgt3,PSWgt4,PSWgt5
      type(Particle),target :: TopQuark(1:2)
      integer, parameter :: plus=1, minus=0
      integer,target :: ExtRef=-1
      double complex :: EpsDotP,SpinCorr_plus_plus,SpinCorr_plus_minus
      type(PtrToParticle) :: Gluons(1:1),Quarks(1:4)
      double precision,parameter :: SpinAvg=dble(4), ColAvg=dble(9)
      real(8)::ColCorr(1:1,1:1)
      real(8),parameter::ColCorr0(1:1,1:1)=(/8.D0/)
      real(8),parameter::ColCorr1(1:1,1:1)=(/8.D0/3.D0/)
      real(8),parameter::ColCorr2(1:1,1:1)=(/-56.D0/3.D0/)
      real(8),parameter::ColCorr3(1:1,1:1)=(/-16.D0/3.D0/)
      real(8),parameter::ColCorr4(1:1,1:1)=(/-16.D0/3.D0/)
      real(8),parameter::ColCorr5(1:1,1:1)=(/-56.D0/3.D0/)
      real(8),parameter::ColCorr6(1:1,1:1)=(/8.D0/3.D0/)
      integer,target :: HelList(1:16,1:4)
      double complex :: MomTmp(0:3)
      logical :: applyPSCut

      SqAmp = 0d0
      if(icorr.eq.0) ColCorr(1:1,1:1)=ColCorr0(1:1,1:1)
      if(icorr.eq.1) ColCorr(1:1,1:1)=ColCorr1(1:1,1:1)
      if(icorr.eq.2) ColCorr(1:1,1:1)=ColCorr2(1:1,1:1)
      if(icorr.eq.3) ColCorr(1:1,1:1)=ColCorr3(1:1,1:1)
      if(icorr.eq.4) ColCorr(1:1,1:1)=ColCorr4(1:1,1:1)
      if(icorr.eq.5) ColCorr(1:1,1:1)=ColCorr5(1:1,1:1)
      if(icorr.eq.6) ColCorr(1:1,1:1)=ColCorr6(1:1,1:1)


      HelList(1,1:4)=(/0,0,0,0/)
      HelList(2,1:4)=(/0,1,0,0/)
      MassTd(1:4) = dsqrt(Mass2Td(1:4))

      MomExt(1:4,1)=MomTd(0:3,1)
      MomExt(1:4,2)=MomTd(0:3,2)
      MomExt(1:4,3)=MomTd(0:3,4)
      MomExt(1:4,4)=MomTd(0:3,3)

      TopQuark(1)%PartType = Top_
      TopQuark(1)%Mom(1:4) = MomTd(0:3,3)
      TopQuark(2)%PartType = ATop_
      TopQuark(2)%Mom(1:4) = MomTd(0:3,4)



!      momentum crossing
      MomTd(0:3,1) = -MomTd(0:3,1)
      MomTd(0:3,2) = -MomTd(0:3,2)



!      set particles
      call vSpi(MomTd(0:3,1),dsqrt(Mass2Td(1)),+1,PolV(0:3,plus,1))
      call vSpi(MomTd(0:3,1),dsqrt(Mass2Td(1)),-1,PolV(0:3,minus,1))
      Quarks(1)%Mom => MomTd(:,1)
      Quarks(1)%PartType => AUp_
      Quarks(1)%ExtRef => ExtRef
      Quarks(1)%Mass2 => Mass2Td(1)
      Quarks(1)%Mass  => MassTd(1)

      call ubarSpi(MomTd(0:3,2),dsqrt(Mass2Td(2)),+1,PolV(0:3,plus,2))
      call ubarSpi(MomTd(0:3,2),dsqrt(Mass2Td(2)),-1,PolV(0:3,minus,2))
      Quarks(2)%Mom => MomTd(:,2)
      Quarks(2)%PartType => Up_
      Quarks(2)%ExtRef => ExtRef
      Quarks(2)%Mass2 => Mass2Td(2)
      Quarks(2)%Mass  => MassTd(2)

      Quarks(3)%Mom => MomTd(:,3)
      Quarks(3)%PartType => Top_
      Quarks(3)%ExtRef => ExtRef
      Quarks(3)%Mass2 => Mass2Td(3)
      Quarks(3)%Mass  => MassTd(3)

      Quarks(4)%Mom => MomTd(:,4)
      Quarks(4)%PartType => ATop_
      Quarks(4)%ExtRef => ExtRef
      Quarks(4)%Mass2 => Mass2Td(4)
      Quarks(4)%Mass  => MassTd(4)




!      sum over helicities
      if( XTopDecays.eq.0 ) then
            SecHel=2
      elseif( XTopDecays.eq.1 ) then
            SecHel=1
      else
          call Error("Error in dipole Tree_QQB_TTb")
      endif


      SqAmp = (0d0,0d0)
      do A0barHel=-1,+1,SecHel
      do A0Hel=-1,+1,SecHel


        IF( XTOPDECAYS.EQ.1 ) THEN
          call HTopBHDecay(TopQuark(2),DKX_HTBH_LO,A0barHel,MomExt(1:4,5:9))
          call HTopBHDecay(TopQuark(1),DKX_HTBH_LO,A0Hel,MomExt(1:4,10:14))
        ELSEIF(XTOPDECAYS.EQ.0 ) THEN
          TopQuark(1)%Helicity = A0Hel
          TopQuark(2)%Helicity = A0barHel
          TopQuark(1)%Mass = MassTd(3)
          TopQuark(2)%Mass = MassTd(4)
          TopQuark(1)%Mass2= Mass2Td(3)
          TopQuark(2)%Mass2= Mass2Td(4)
          call HTopBHDecay(TopQuark(2),DKX_HTBH_LO,A0barHel,MomExt(1:4,5:9))
          call HTopBHDecay(TopQuark(1),DKX_HTBH_LO,A0Hel,MomExt(1:4,10:14))
        ENDIF

      Quarks(3)%Pol => TopQuark(1)%Pol
      Quarks(3)%Helicity => TopQuark(1)%Helicity
      Quarks(4)%Pol => TopQuark(2)%Pol
      Quarks(4)%Helicity => TopQuark(2)%Helicity




      do iHel=1,2
      Quarks(2)%Pol => PolV(:,HelList(iHel,2),2)
      Quarks(2)%Helicity => HelList(iHel,2)

!      calc currents
      Res(0:3) = cur_f_4f((/Gluons(1)/),(/Quarks(2),Quarks(3),Quarks(4)/),Quarks(1)%PartType,(/0,0,0,0,0/),0)
      Amp(1,plus)  = psp1_(Res(0:3),PolV(0:3,plus,1))
      Amp(1,minus) = psp1_(Res(0:3),PolV(0:3,minus,1))


      do col =1,1
      do colP=1,1
        SqAmp = SqAmp + ColCorr(colP,col) * ( dconjg(Amp(colP,plus))*Amp(col,plus) + dconjg(Amp(colP,minus))*Amp(col,minus) )
      enddo
      enddo

      enddo
      enddo
      enddo

      SqAmp = alpha_s4Pi**2 / SpinAvg / ColAvg * SqAmp


!      momentum crossing backwards
      MomTd(0:3,1) = -MomTd(0:3,1)
      MomTd(0:3,2) = -MomTd(0:3,2)

      return
      END FUNCTION








      FUNCTION Tree_GG_TTb_00(MomTd,Mass2Td) Result(SqAmp)! this needs to be modified
      use modProcess
      use modParameters
      use modMyRecurrence
      use modKinematics
      use ModExoticDecay
      implicit none
      double precision,parameter :: Split_A=1d0
      double complex SqAmp,Amp(2,0:1),Res(0:3)
      integer col,colP,iHel,icorr,SecHel,A0barHel,A0Hel,HTHel,HTbarHel
      double complex,target :: MomTd(0:3,1:4)
      double precision,target :: Mass2Td(1:4),MassTd(1:4)
      double complex, target :: PolV(0:3,0:1,1:4)
!       double precision :: PSWgt2,PSWgt3,MomDK_ATop(0:3,1:3),MomDK_Top(0:3,1:3)
      type(Particle),target :: TopQuark(1:2)
      integer, parameter :: plus=1, minus=0
      integer,target :: ExtRef=-1
      double complex :: EpsDotP,SpinCorr_plus_plus,SpinCorr_plus_minus
      type(PtrToParticle) :: Gluons(1:2),Quarks(1:2)
      double precision,parameter :: SpinAvg=dble(4), ColAvg=dble(64)
      double precision :: ColCorr(1:2,1:2)
      real(8),parameter::ColCorr0(1:2,1:2)=(/64.D0/3.D0,-8.D0/3.D0,-8.D0/3.D0,64.D0/3.D0/)
      real(8),parameter::ColCorr1(1:2,1:2)=(/-72.D0,0.D0,0.D0,-72.D0/)
      real(8),parameter::ColCorr2(1:2,1:2)=(/-64.D0,8.D0,8.D0,8.D0/)
      real(8),parameter::ColCorr3(1:2,1:2)=(/8.D0,8.D0,8.D0,-64.D0/)
      real(8),parameter::ColCorr4(1:2,1:2)=(/8.D0,8.D0,8.D0,-64.D0/)
      real(8),parameter::ColCorr5(1:2,1:2)=(/-64.D0,8.D0,8.D0,8.D0/)
      real(8),parameter::ColCorr6(1:2,1:2)=(/-8.D0/9.D0,-80.D0/9.D0,-80.D0/9.D0,-8.D0/9.D0/)
      integer,target :: HelList(1:4,1:3)

      HelList(1,1:3)=(/0,0,0/)
      HelList(2,1:3)=(/1,0,0/)
!       HelList(3,1:3)=(/0,1,0/)
!       HelList(4,1:3)=(/1,1,0/)
      MassTd(1:4) = dsqrt(Mass2Td(1:4))

!      momentum crossing
      MomTd(0:3,1) = -MomTd(0:3,1)
      MomTd(0:3,2) = -MomTd(0:3,2)


              TopQuark(1)%PartType = Top_
              TopQuark(1)%Mom(1:4) = MomTd(0:3,3)
              TopQuark(2)%PartType = ATop_
              TopQuark(2)%Mom(1:4) = MomTd(0:3,4)


!      set particles
      call pol_mless(MomTd(0:3,1),+1,PolV(0:3,plus,1))
      call pol_mless(MomTd(0:3,1),-1,PolV(0:3,minus,1))

      call pol_mless(MomTd(0:3,2),+1,PolV(0:3,plus,2))
      call pol_mless(MomTd(0:3,2),-1,PolV(0:3,minus,2))
      Gluons(2)%Mom => MomTd(:,2)
      Gluons(2)%PartType => Glu_
      Gluons(2)%ExtRef => ExtRef
      Gluons(2)%Mass2 => Mass2Td(2)
      Gluons(2)%Mass  => MassTd(2)

      Quarks(1)%Mom => MomTd(:,3)
      Quarks(1)%PartType => Top_
      Quarks(1)%ExtRef => ExtRef
      Quarks(1)%Mass2 => Mass2Td(3)
      Quarks(1)%Mass  => MassTd(3)

      Quarks(2)%Mom => MomTd(:,4)
      Quarks(2)%PartType => ATop_
      Quarks(2)%ExtRef => ExtRef
      Quarks(2)%Mass2 => Mass2Td(4)
      Quarks(2)%Mass  => MassTd(4)

!      sum over helicities
      if( XTopDecays.eq.0 ) then
            SecHel=2
      elseif( XTopDecays.eq.1 ) then
            SecHel=1
      else
          call Error("Error in dipole Tree_GG_TTb")
      endif


      SqAmp = (0d0,0d0)


      ColCorr(1:2,1:2)=ColCorr0(1:2,1:2)


      do A0barHel=-1,+1,SecHel
      do A0Hel=-1,+1,SecHel
        IF( XTOPDECAYS.EQ.1 ) THEN
          call HTopBHDecay(TopQuark(2),DKX_HTBH_LO,A0barHel,MomExt(1:4,5:9))
          call HTopBHDecay(TopQuark(1),DKX_HTBH_LO,A0Hel,MomExt(1:4,10:14))
        ELSEIF(XTOPDECAYS.EQ.0 ) THEN
          TopQuark(1)%Helicity = A0Hel
          TopQuark(2)%Helicity = A0barHel
          TopQuark(1)%Mass = MassTd(3)
          TopQuark(2)%Mass = MassTd(4)
          TopQuark(1)%Mass2= Mass2Td(3)
          TopQuark(2)%Mass2= Mass2Td(4)
          call HTopBHDecay(TopQuark(2),DKX_HTBH_LO,A0barHel,MomExt(1:4,5:9))
          call HTopBHDecay(TopQuark(1),DKX_HTBH_LO,A0Hel,MomExt(1:4,10:14))
        ENDIF


        Quarks(1)%Pol => TopQuark(1)%Pol
        Quarks(2)%Pol => TopQuark(2)%Pol
        Quarks(1)%Helicity => TopQuark(1)%Helicity
        Quarks(2)%Helicity => TopQuark(2)%Helicity

      do iHel=1,2

      Gluons(2)%Pol => PolV(:,HelList(iHel,1),2)
      Gluons(2)%Helicity => HelList(iHel,1)
!       Quarks(1)%Pol => PolV(:,HelList(iHel,2),3)
!       Quarks(1)%Helicity => HelList(iHel,2)
!       Quarks(2)%Pol => PolV(:,HelList(iHel,3),4)
!       Quarks(2)%Helicity => HelList(iHel,3)

!      calc currents
      Res(0:3) = cur_g_2f( (/Gluons(2)/),(/Quarks(2),Quarks(1)/),(/2,1,0,0/) )
      Amp(1,plus)  = Res(0:3).dot.PolV(0:3,plus,1)
      Amp(1,minus) = Res(0:3).dot.PolV(0:3,minus,1)

      Res(0:3) = cur_g_2f( (/Gluons(2)/),(/Quarks(2),Quarks(1)/),(/2,0,0,1/) )
      Amp(2,plus)  = Res(0:3).dot.PolV(0:3,plus,1)
      Amp(2,minus) = Res(0:3).dot.PolV(0:3,minus,1)


      do col =1,2
      do colP=1,2

        SqAmp = SqAmp + ColCorr(colP,col) * Split_A*( dconjg(Amp(colP,plus)) *Amp(col,plus)     &
                                                                   + dconjg(Amp(colP,minus))*Amp(col,minus) )
      enddo
      enddo

      enddo

      enddo
      enddo
      SqAmp = alpha_s4Pi**2 / SpinAvg / ColAvg *SqAmp


!      momentum crossing backwards
      MomTd(0:3,1) = -MomTd(0:3,1)
      MomTd(0:3,2) = -MomTd(0:3,2)

      return
      END FUNCTION








END MODULE
