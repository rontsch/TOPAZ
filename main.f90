PROGRAM TOPAZ
use ModParameters
use ModProcess
use ModKinematics
use ModMyRecurrence
use ModJPsiFrag
use ifport
implicit none
include "vegas_common.f"
real(8) :: VG_Result,VG_Error,chi2
!DEC$ IF(_UseMPIVegas .EQ.1)
include 'mpif.h'
integer ::ierror
   call MPI_INIT(ierror)
   call MPI_COMM_RANK(MPI_COMM_WORLD,MPI_Rank,ierror)
!DEC$ ELSE
   MPI_Rank=0
!DEC$ ENDIF


   call GetCommandlineArgs()
   call Init_cur_2_2f(4)
   call setDim(4,4)
   call InitPDFs()
   call InitParameters()
   call InitHisto()
   call InitPSCuts()
   call InitKirillParameters()
   call InitProcess()
   call InitAmps()
   call InitVegas()
   call InfoPrimAmps("PrimAmpInfo.txt")
   call OpenFiles()
   if( MPI_Rank.eq.0 ) then   
      call WriteParameters(6)   ! stdout
   endif
   if( TopDecays.eq.5 .or. TopDecays.eq.6 ) call fitFF(MuFrag)

   if( MPI_Rank.eq.0 ) print *, "Running"
   if( MPI_Rank.eq.0 ) call cpu_time(time_start)
!DEC$ IF(_UseMPIVegas .EQ.0)
   call StartVegas(VG_Result,VG_Error,Chi2)
!DEC$ ELSE
   call StartPVegas(VG_Result,VG_Error,Chi2)
!DEC$ ENDIF
   if( MPI_Rank.eq.0 ) then
      call cpu_time(time_end)
!       call WriteHisto(14,1,0d0,0d0,VG_Result,VG_Error,Chi2,time_end-time_start)  ! Histogram file (unit=14)
!       call PlotVegas()
      print *, "Done (",(time_end-time_start)/60d0,") minutes"
   endif
   call CloseFiles()


!DEC$ IF(_UseMPIVegas .EQ.1)
   call MPI_FINALIZE(ierror)
!DEC$ ENDIF


END PROGRAM







SUBROUTINE GetCommandlineArgs()
use ModParameters
use ModKinematics
use ifport
implicit none
character :: arg*(100)
character :: env*(31),ColliderStr*(10),ColliderDirStr*(10),ProcessStr*(3),CorrectionStr*(10),FileTag*(50),DataDir*(80),SeedStr*(20),MuStr*(7),ObsStr*(6)
integer :: NumArgs,NArg,IDipAlpha(1:5),iDKAlpha(1:3),DipAlpha2
logical :: dirresult


   Collider=-1
   Process=-1
   Correction=-1
   ObsSet=-1
   PDFSet=1
   LHAPDFMember = 0
   NLOParam=1
   TopDecays=-100
   XTopDecays=-100
   ZDecays=-100
   HDecays=-100
   HelSampling=.false.
   FirstLOThenVI=.false.
   m_Top=173d0*GeV
   m_STop=350d0*GeV
   m_HTop=500d0*GeV
   m_Zpr=1500d0*GeV
   Ga_Zpr=m_Zpr*0.01d0
   Q_top = Q_up
   MuRen=m_Top
   MuFac=m_Top
   MuFrag=m_Top
   Fragm_Func_Type=2
   alpha_frag=0.66d0
   beta_frag =12.39d0
   delta_frag=14.97d0
   VegasIt0=-1
   VegasNc0=-1
   VegasIt1=-1
   VegasNc1=-1
   GridIO=0
   Unweighted = .false.
   HistoFile=""
   FileTag=""
   DataDir="./"
   MuStr=""
   ObsStr=""
   GridFile="grid"
   VegasSeed=19
   DKRE_switch=0
   iDipAlpha(1:5)=0
   DipAlpha2=1d0
! default for BSM top-Z couplings
   AbsDelF1A=0d0
   AbsDelF1V=0d0
   RelDelF1A=0d0
   RelDelF1V=0d0
   RelDelF2A=0d0
   RelDelF2V=0d0
! default for BSM top-photon couplings   
   DelGam2V=0d0
   DelGam2A=0d0
! default for BSM top-Higgs couplings
   kappaTTBH=1d0
   kappaTTBH_tilde=0d0

   
   
   NumArgs = NArgs()-1
   do NArg=1,NumArgs
    call GetArg(NArg,arg)
    if( arg(1:9).eq."Collider=" ) then
        read(arg(10:11),*) Collider
    elseif( arg(1:8).eq."Process=" ) then
        read(arg(9:11),*) Process
    elseif( arg(1:11).eq."Correction=" ) then
        read(arg(12:13),*) Correction
    elseif( arg(1:7).eq."ObsSet=" ) then
        read(arg(8:9),*) ObsSet
        write(ObsStr,"(I2)") ObsSet
    elseif( arg(1:5).eq."MTop=" ) then
        read(arg(6:10),*) m_Top
        MuRen=m_Top
        MuFac=m_Top
        MuFrag=m_Top
    elseif( arg(1:6).eq."MStop=" ) then
        read(arg(7:11),*) m_STop
        MuRen=m_STop
        MuFac=m_STop
    elseif( arg(1:6).eq."MHTop=" ) then
        read(arg(7:11),*) m_HTop
        MuRen=m_HTop
        MuFac=m_HTop
    elseif( arg(1:5).eq."MZpr=" ) then
        read(arg(6:10),*) m_Zpr
        MuRen=m_Zpr
        MuFac=m_Zpr
    elseif( arg(1:6).eq."GaZpr=" ) then
        read(arg(7:11),*) Ga_Zpr
    elseif( arg(1:8).eq."nGluRad=" ) then
        read(arg(9:10),*) nGluRadContr
    elseif( arg(1:10).eq."TTBZdebug=" ) then
        read(arg(11:12),*) TTBZ_DebugSwitch
    elseif( arg(1:5).eq."XQTop" ) then
        Q_Top = -4d0/3d0
    elseif( arg(1:7).eq."PDFSet=" ) then
        read(arg(8:9),*) PDFSet
    elseif( arg(1:7).eq."FFType=" ) then
        read(arg(8:9),*) Fragm_Func_Type
    elseif( arg(1:5).eq."FFal=" ) then
        read(arg(6:16),*) alpha_frag
    elseif( arg(1:5).eq."FFbe=" ) then
        read(arg(6:16),*) beta_frag
    elseif( arg(1:5).eq."FFde=" ) then
        read(arg(6:16),*) delta_frag
    elseif( arg(1:9).eq."NLOParam=" ) then
        read(arg(10:11),*) NLOParam
    elseif( arg(1:6).eq."MuRen=" ) then
        read(arg(7:11),*) MuRen
!         if( MuRen.ne.m_Top ) write(MuStr,"(F4.2)") MuRen
    elseif( arg(1:6).eq."MuFac=" ) then
        read(arg(7:11),*) MuFac
    elseif( arg(1:7).eq."MuFrag=" ) then
        read(arg(8:11),*) MuFrag
    elseif( arg(1:6).eq."TopDK=" ) then
        read(arg(7:9),*) TopDecays
    elseif( arg(1:7).eq."XTopDK=" ) then
        read(arg(8:10),*) XTopDecays
    elseif( arg(1:4).eq."ZDK=" ) then
        read(arg(5:7),*) ZDecays
    elseif( arg(1:4).eq."HDK=" ) then
        read(arg(5:7),*) HDecays
    elseif( arg(1:9).eq."VegasIt0=" ) then
        read(arg(10:11),*) VegasIt0
    elseif( arg(1:9).eq."VegasIt1=" ) then
        read(arg(10:11),*) VegasIt1
    elseif( arg(1:9).eq."VegasNc0=" ) then
        read(arg(10:20),*) VegasNc0
    elseif( arg(1:9).eq."VegasNc1=" ) then
        read(arg(10:20),*) VegasNc1
    elseif( arg(1:10).eq."VegasSeed=" ) then
        read(arg(11:17),*) VegasSeed
    elseif( arg(1:9).eq."GridFile=" ) then
        read(arg(10:41),*) GridFile
    elseif( arg(1:7).eq."GridIO=" ) then
        read(arg(8:10),*) GridIO
    elseif( arg(1:10).eq."HistoFile=" ) then
        read(arg(11:41),*) HistoFile
    elseif( arg(1:8).eq."FileTag=" ) then
        read(arg(9:59),*)  FileTag
        if( FileTag.eq."." ) FileTag=""
    elseif( arg(1:8).eq."DataDir=" ) then
        DataDir(:)=trim(arg(9:100))
        ! note copying via read(arg(:),*)  DataDir does not work because the strings are terminated when "\" is encountered
    elseif( arg(1:10) .eq. "AbsDelF1A=" ) then
        read(arg(11:16),*) AbsDelF1A
    elseif( arg(1:10) .eq. "AbsDelF1V=" ) then
        read(arg(11:16),*) AbsDelF1V
    elseif( arg(1:10) .eq. "RelDelF1A=" ) then
        read(arg(11:16),*) RelDelF1A
    elseif( arg(1:10) .eq. "RelDelF1V=" ) then
        read(arg(11:16),*) RelDelF1V
    elseif( arg(1:10) .eq. "RelDelF2A=" ) then
        read(arg(11:16),*) RelDelF2A
    elseif( arg(1:10) .eq. "RelDelF2V=" ) then
        read(arg(11:16),*) RelDelF2V
    elseif( arg(1:9) .eq. "DelGam2V=" ) then
        read(arg(10:16),*) DelGam2V
    elseif( arg(1:9) .eq. "DelGam2A=" ) then
        read(arg(10:16),*) DelGam2A
     elseif( arg(1:6) .eq. "kappa=") then
        read(arg(7:13),*) kappaTTBH
     elseif( arg(1:12) .eq. "kappa_tilde=") then
        read(arg(13:18),*) kappaTTBH_tilde
    elseif( arg(1:9).eq."DipAlpha=" ) then
        read(arg(10:10),*) iDipAlpha(1)
        read(arg(11:11),*) iDipAlpha(2)
        read(arg(12:12),*) iDipAlpha(3)
        read(arg(13:13),*) iDipAlpha(4)
        read(arg(14:14),*) iDipAlpha(5)
        alpha_ii = 10d0**(-iDipAlpha(1))
        alpha_if = 10d0**(-iDipAlpha(2))
        alpha_fi = 10d0**(-iDipAlpha(3))
        alpha_ff = 10d0**(-iDipAlpha(4))
        alpha_DK = 10d0**(-iDipAlpha(5))
    elseif( arg(1:8).eq."DKAlpha=" ) then
        read(arg(9:9),*)   iDKAlpha(1)
        read(arg(10:10),*) iDKAlpha(2)
        read(arg(11:11),*) iDKAlpha(3)
    elseif( arg(1:10).eq."DipAlpha2=" ) then
        read(arg(11:11),*) DipAlpha2
    elseif( arg(1:8).eq."HelSamp=" ) then
        read(arg(9:9),*) HelSampling
    elseif( arg(1:5).eq."DKRE=" ) then
        read(arg(6:7),*) DKRE_switch
    endif
   enddo
   write(MuStr,"(F5.2)") MuRen

   if( DipAlpha2.eq.0d0 ) then
       print *, "DipAlpha2 cannot ne zero"
       stop
   endif
   if (alpha_ii.ne.1d0) alpha_ii = DipAlpha2 * alpha_ii
   if (alpha_if.ne.1d0) alpha_if = DipAlpha2 * alpha_if
   if (alpha_fi.ne.1d0) alpha_fi = DipAlpha2 * alpha_fi
   if (alpha_ff.ne.1d0) alpha_ff = DipAlpha2 * alpha_ff

   if ( (AbsDelF1A .ne. 0d0 .and. RelDelF1A .ne. 0d0) .or. &
        (AbsDelF1V .ne. 0d0 .and. RelDelF1V .ne. 0d0) ) then
      print *, "Make up your mind! Abs or relative delta Z-top?"
      stop
   endif

   DeltaF1A=RelDelF1A
   DeltaF1V=RelDelF1V
   if (AbsDelF1A .ne. 0d0 .or. AbsDelF1V .ne. 0d0 ) then
      DeltaF1A=AbsDelF1A/(couplZTT_left_SM-couplZTT_right_SM)*2d0
      DeltaF1V=AbsDelF1V/(couplZTT_left_SM+couplZTT_right_SM)*2d0
   endif
   DeltaF2A=RelDelF2A
   DeltaF2V=RelDelF2V
   


   alpha_DKTfi = alpha_DK; alpha_DKTff = alpha_DK; alpha_DKWff = alpha_DK;
   if(iDKAlpha(1).ne.0) then
      alpha_DKTfi = dble(iDKAlpha(1)) * alpha_DKTfi
   endif
   if(iDKAlpha(2).ne.0) then
      alpha_DKTff = dble(iDKAlpha(2)) * alpha_DKTff
   endif
   if(iDKAlpha(3).ne.0) then
      alpha_DKWff = dble(iDKAlpha(3)) * alpha_DKWff
   endif


    if(Collider.eq.-1 .or. Process.eq.-1 .or. Correction.eq.-1 .or. TopDecays.eq.-100 .or. ObsSet.eq.-1) then
          write(*,'(A)') "not enough input parameter"
          write(*,'(A)') "required:   Collider,Process,Correction,TopDK,ObsSet"
          write(*,'(A)') "Collider:   1=LHC(14TeV), 11..13=LHC(7,8,13 TeV), 2=Tevatron, 5..7=e+e- (350,500,1000 GeV)"
          write(*,'(A)') "Process:    see ProcessInfo.txt"
          write(*,'(A)') "Correction: 0=LO, 1=VI, 2=RE, 3=ID, 4=VI in top decay, 5=RE in top decay"
          write(*,'(A)') "TopDK:      0=stable tops, 1=dilept, 2=full hadr, 3=l-&jets, 4=l+&jets"
          write(*,'(A)') "ObsSet:     see mod_Kinematics.f90"
          stop
    endif
    if( Process.ge.41 .and. Process.le.59 ) then
          if( XTopDecays.eq.-100 ) then 
              print *, "not enough input parameter"
              print *, "required: XTopDK:      0=stable, 1=Htop-->vector+top, 2=HTop-->scalar+top, 3=Stop-->Chi0+top"
              stop
          endif
    endif
    if( Process.ge.71 .and. Process.le.79 ) then
          if( ZDecays.eq.-100 ) then 
              print *, "not enough input parameter"
              print *, "required: ZDK:      0=stable, 1=Z-->l+ l-, 2=Z-->nu nubar"
              stop
          endif
          if( (ZDecays.gt.0 .and. TopDecays.eq.0) .OR. (ZDecays.eq.0 .and. TopDecays.ne.0) ) then
              print *, "if the Z boson decays then the tops also have to decay (and vice versa)"
              stop
          endif
    endif
    if( Process.ge.81 .and. Process.le.89 ) then
          ZDecays=-2
! hopefully this isnt needed...
!          print *, "Please set M_Z=0 in ModParameters, recompile and remove this line."; stop
          if( TopDecays.ne.0 ) then
              print *, "tops are not yet allowed to decay for process",Process
!              stop
          endif
    endif
    if( Process.ge.101 .and. Process.le.109 ) then
          if( HDecays.eq.-100 ) then 
              print *, "not enough input parameter"
              print *, "required: HDK:      0=stable, 1=H-->ZZ, 2=H-->gaga"
              stop
          endif
    endif

    if((Correction.eq.3 .or. TopDecays.eq.5 .or. TopDecays.eq.6) .and. HelSampling) then
          print *, "Helicity sampling is not allowed here. This is simpliy due to assignments of random numbers in mod_CrossSection.f90"
    endif

    if(Process.lt.10) then
      write(ProcessStr,"(I1)") Process
      ProcessStr="0"//trim(ProcessStr)
    elseif(Process.lt.100) then
      write(ProcessStr,"(I2)") Process
    else
      write(ProcessStr,"(I3)") Process
    endif

    if( Collider.eq.2 ) then
         AlgoType = +1       ! kT
    else
         AlgoType = -1       ! anti-kT    
    endif


    if(Correction.eq.0) then
        if(NLOParam.le.1) then
          CorrectionStr = "LOLO"
        elseif(NLOParam.eq.2) then
          CorrectionStr = "LO"
        endif
    elseif(Correction.eq.1) then
        CorrectionStr = "1L"
    elseif(Correction.eq.2) then
        CorrectionStr = "RE"
    elseif(Correction.eq.3) then
        CorrectionStr = "ID"
    elseif(Correction.eq.4) then
        CorrectionStr = "DK1L"
    elseif(Correction.eq.5 .and. DKRE_switch.eq.1) then
        CorrectionStr = "DKRE_a"
    elseif(Correction.eq.5 .and. DKRE_switch.eq.2) then
        CorrectionStr = "DKRE_b"
    elseif(Correction.eq.5 .and. DKRE_switch.eq.0) then
        CorrectionStr = "DKRE"
    endif


    if(VegasSeed.eq.19) then
      SeedStr=""
    elseif(VegasSeed.lt.10) then
      write(SeedStr,"(I1)") VegasSeed
      SeedStr="_00"//trim(SeedStr)
    elseif(VegasSeed.lt.100) then
      write(SeedStr,"(I2)") VegasSeed
      SeedStr="_0"//trim(SeedStr)
    elseif(VegasSeed.lt.1000) then
      write(SeedStr,"(I3)") VegasSeed
      SeedStr="_"//trim(SeedStr)
    else
      print *, "Vegas seed too big"
      stop
    endif
    if( TTBZ_DebugSwitch.eq.1 ) then  
       SeedStr=trim(seedStr)//"_bos"
    elseif( TTBZ_DebugSwitch.eq.2 ) then  
       SeedStr=trim(seedStr)//"_fer"
    elseif( TTBZ_DebugSwitch.eq.3 ) then  
       SeedStr=trim(seedStr)//"_g5r"
    endif

   if(ObsSet.lt.10) then
      write(ObsStr,"(I1)") ObsSet
      ObsStr="0"//trim(ObsStr)
   endif

    if( Collider.eq.1 ) then
        ColliderDirStr="LHC14"
        ColliderStr="LHC"
    elseif( Collider.eq.11 ) then
        ColliderDirStr="LHC7"
        ColliderStr="LHC"
    elseif( Collider.eq.12 ) then
        ColliderDirStr="LHC8"
        ColliderStr="LHC"
    elseif( Collider.eq.13 ) then
        ColliderDirStr="LHC13"
        ColliderStr="LHC"
    elseif( Collider.eq.2 ) then
        ColliderDirStr="TEV"
        ColliderStr="TEV"
    elseif( Collider.eq.5 ) then
        ColliderDirStr="ee350"
        ColliderStr="ee"
    elseif( Collider.eq.6 ) then
        ColliderDirStr="ee500"
        ColliderStr="ee"
    elseif( Collider.eq.7 ) then
        ColliderDirStr="ee1000"
        ColliderStr="ee"
    endif


    if( Q_top.ne.Q_up ) then
        MuStr=trim(MuStr)//"_XQ"
    endif


    dirresult = makedirqq(trim(DataDir)//trim(ColliderDirStr)//"_"//trim(ObsStr)//"_"//trim(adjustl(MuStr)))! need adjustl to cut off leading spaces for Mu<10.00 (=1TeV)
    dirresult = makedirqq(trim(DataDir)//trim(ColliderDirStr)//"_"//trim(ObsStr)//"_"//trim(adjustl(MuStr))//"/"//trim(ProcessStr))
    if(dirresult) print *, "created directory "//trim(DataDir)//trim(ColliderDirStr)//"_"//trim(ObsStr)//"_"//trim(adjustl(MuStr))//"/"//trim(ProcessStr)


    if( ObsSet.eq.8 ) then!   spin correlations with R
            if(TopDecays.eq.+1) FileTag=trim(FileTag)//"_c"
            if(TopDecays.eq.-1) FileTag=trim(FileTag)//"_u"
            print *, "Remember: MRST PDFs, Ellis-Soper Recombination"
    endif


    if(HistoFile.eq."") then
        HistoFile = trim(DataDir)//trim(ColliderDirStr)//"_"//trim(ObsStr)//"_"//trim(adjustl(MuStr))//"/"//trim(ProcessStr)//"/"//trim(ColliderStr)//"."//trim(ProcessStr)//"."//trim(CorrectionStr)//trim(SeedStr)//trim(FileTag)
    endif

   if( trim(GridFile).eq."grid" ) then
      GridFile = trim(DataDir)//trim(ColliderDirStr)//"_"//trim(ObsStr)//"_"//trim(adjustl(MuStr))//"/"//trim(ProcessStr)//"/"//trim(ColliderStr)//"."//trim(ProcessStr)//trim(FileTag)//".1L."//trim(GridFile)
   endif

return
END SUBROUTINE






SUBROUTINE WriteParameters(TheUnit)
use ModParameters
use ModKinematics
implicit none
integer TheUnit


!DEC$ IF(_CheckMomenta .EQ.1)
    print *, "_CheckMomenta activated!"
!DEC$ ENDIF

   write(TheUnit,"(A)") "# Program parameters:"
   write(TheUnit,"(A,I2,A,F8.3,A)") "# Collider=",Collider," (",Collider_Energy*1d-1," TeV)"
   write(TheUnit,"(A,I2)") "# ObsSet=",ObsSet
   write(TheUnit,"(A,I3)") "# Process=",Process
   write(TheUnit,"(A,I2)") "# Master Process=",MasterProcess
   write(TheUnit,"(A,I2)") "# Correction=",Correction
#if _UseLHAPDF==1
   write(TheUnit,"(A,A,A,I3)") "# LHAPDF Set ",trim(PDFSetString), ", member ",LHAPDFMember
#else
   write(TheUnit,"(A,I2,A)") "# PDF Set=",PDFSet,trim(PDFSetString)
#endif   
   write(TheUnit,"(A,I2)") "# NLO Parameter=",NLOParam
   write(TheUnit,"(A,I2)") "# Top Decays=",TopDecays
   write(TheUnit,"(A,F9.3,A)") "# MuRen=",MuRen*100," GeV"
   write(TheUnit,"(A,F9.3,A)") "# MuFac=",MuFac*100," GeV"
   if( Q_top.ne.Q_up ) write(TheUnit,"(A,F13.9)") "# Q_top=",Q_top
   if( Correction.eq.2 .or. Correction.eq.3 .or. Correction.eq.4 .or. Correction.eq.5 ) then
        write(TheUnit,"(A,PE9.2,PE9.2,PE9.2,PE9.2,PE9.2,A)") "# Alpha Parameters (ii if fi ff DK)=(",alpha_ii,alpha_if,alpha_fi,alpha_ff,alpha_DK,")"
        write(TheUnit,"(A,PE9.2,PE9.2,PE9.2,A)") "# DK Alpha Parameters (Tfi Tff Wff)=(",alpha_DKTfi,alpha_DKTff,alpha_DKWff,")"
        write(TheUnit,"(A,F13.6)") "# Kappa Parameter  kappa_ff=",kappa_ff
   endif
   if( TOPDECAYS.EQ.5 .OR. TOPDECAYS.EQ.6  ) then
      write(TheUnit,"(A,F7.2,A)") "# MuFrag=",MuFrag*100," GeV"
      write(TheUnit,"(A,I3)") "# Fragmentation function type=",Fragm_Func_Type
      write(TheUnit,"(A,F10.5,F10.5,F10.5)") "# parameters (alpha,beta,delta)=",alpha_frag,beta_frag,delta_frag
   endif

    if(MuRen.ne.MuFac) then
       write(TheUnit,*) "# MuRen.ne.MuFac: check that this is correctly implemented in the dipole routines!"
    endif

    write(TheUnit,"(A,F13.9,A)") "# alpha_s(MuRen)=",alpha_s*RunAlphaS(NLOParam,MuRen)
    write(TheUnit,"(A,F13.9,A)") "# 1/alpha_em=",1d0/alpha
    write(TheUnit,"(A,F13.9,A)") "# SinThetaW^2=",sw2
    if(NLOParam.eq.1) then
       write(TheUnit,"(A)") "# one loop running"
    elseif(NLOParam.eq.2) then
       write(TheUnit,"(A)") "# two loop running"
    else
       write(TheUnit,"(A)") "# no alpha_s running"
    endif
    
    write(TheUnit,'(A,F10.5,A)') "# m(Z)=",m_Z*100d0, " GeV"
    write(TheUnit,'(A,F10.5,A)') "# Gamma(Z)=",Ga_ZExp*100d0, " GeV"
    write(TheUnit,'(A,F10.5,A)') "# m(W)=",m_W*100d0, " GeV"
    write(TheUnit,'(A,F10.5,A)') "# Gamma(W)=",Ga_W(0)*100d0, " GeV"
    if( ObsSet.ge.60 .and. ObsSet.le.69 ) then
        write(TheUnit,'(A,F10.5,A)') "# m(Zpr)=",m_Zpr*100d0, " GeV"
        write(TheUnit,'(A,F10.5,A)') "# Gamma(Zpr)=",Ga_Zpr*100d0, " GeV"
        write(TheUnit,'(A,F10.5)') "# gL_Zpr(top_)=",gL_Zpr(top_)
        write(TheUnit,'(A,F10.5)') "# gR_Zpr(top_)=",gR_Zpr(top_)
        write(TheUnit,'(A,F10.5)') "# gL_Zpr(dn_)=",gL_Zpr(dn_)
        write(TheUnit,'(A,F10.5)') "# gR_Zpr(dn_)=",gR_Zpr(dn_)
    endif
    if ( (ObsSet.ge.50 .and. ObsSet.le.59) .or. (ObsSet.ge.70 .and. ObsSet.le.79) .or. (ObsSet .ge. 20 .and. ObsSet .le. 30)) then
       write(TheUnit,"(A,I2)") "# Z Decays=",ZDecays
       write(TheUnit,'(A,F10.5)') '# DeltaF1V=',DeltaF1V
       write(TheUnit,'(A,F10.5)') '# DeltaF1A=',DeltaF1A
       write(TheUnit,'(A,F10.5)') '# DeltaF2V=',DeltaF2V
       write(TheUnit,'(A,F10.5)') '# DeltaF2A=',DeltaF2A
       write(TheUnit,'(A,F10.5)') '# DelGam2V=',DelGam2V
       write(TheUnit,'(A,F10.5)') '# DelGam2A=',DelGam2A
       write(TheUnit,'(A,F8.5)') '# SM ttbZ vector=',couplZTT_V_SM
       write(TheUnit,'(A,F8.5)') '# SM ttbZ axial= ',couplZTT_A_SM
       write(TheUnit,'(A,F8.5)') '# BSM ttbZ vector= ',couplZTT_V_SM * (1d0 + DeltaF1V)
       write(TheUnit,'(A,F8.5)') '# BSM ttbZ axial=  ',couplZTT_A_SM * (1d0 + DeltaF1A)
       write(TheUnit,'(A,F8.5)') '# BSM ttbZ vector2=',DeltaF2V
       write(TheUnit,'(A,F8.5)') '# BSM ttbZ axial2= ',DeltaF2A
    endif
    if ( (ObsSet.ge.80 .and. ObsSet.le.89) .or. (ObsSet .ge. 91 .and. ObsSet .le.99)  ) then
       write(TheUnit,'(A,F10.5,A)') "# m(H)=",m_H*100d0, " GeV"
       write(TheUnit,'(A,F10.5,A)') "# Gamma(H)=",Ga_H*100d0, " GeV"    
       write(TheUnit,"(A,I2)") "# H Decays=",HDecays
       write(TheUnit,'(A,F10.5,A)') "# vev=",Vev*100d0, " GeV"
       write(TheUnit,"(A,F10.5)") "# kappa=",kappaTTBH  
       write(TheUnit,"(A,F10.5)") "# kappa_tilde=",kappaTTBH_tilde
       
    endif    
    if( m_Top.eq.m_SMTop ) then 
        write(TheUnit,'(A,F8.3,A)') "# m(top)=",m_Top *100d0, " GeV"
    else
        write(TheUnit,'(A,F8.3,A)') "# m(top)=",m_SMTop *100d0, " GeV"
    endif
    write(TheUnit,"(A,F10.6)") "# Width expansion factor=",WidthExpansion
    write(TheUnit,"(A,F10.6,A)") "# Gamma_Top(LO) =",Ga_Top(0)*100d0," GeV"
    write(TheUnit,"(A,F10.6,A)") "# Gamma_Top(NLO)=",(Ga_Top(0)+Ga_Top(1))*100d0," GeV"
    write(TheUnit,"(A,F10.6,A)") "# Gamma_W(LO) =",Ga_W(0)*100d0," GeV"
    write(TheUnit,"(A,F10.6,A)") "# Gamma_W(NLO)=",(Ga_W(0)+Ga_W(1))*100d0," GeV"
    if( ObsSet.ge.31 .and. ObsSet.le.39) then
        write(TheUnit,'(A,F8.3,A)') "# m(Htop)=",m_HTop *100d0, " GeV"
      if( XTOPDECAYS.eq.1 .or. XTOPDECAYS.eq.2 ) then
        if( XTOPDECAYS.eq.1) write(TheUnit,'(A,F8.3,A)') "# m(BH)=",m_BH *100d0, " GeV"
        if( XTOPDECAYS.eq.2) write(TheUnit,'(A,F8.3,A)') "# m(A0)=",m_A0 *100d0, " GeV"
        write(TheUnit,"(A,F10.6,A)") "# Gamma_HTop(LO) =",Ga_HTop(0)*100d0," GeV"
        write(TheUnit,"(A,F10.6,A)") "# Gamma_HTop(NLO)=",(Ga_HTop(0)+Ga_HTop(1))*100d0," GeV"
      endif
    endif
    if( ObsSet.ge.41 .and. ObsSet.le.49) then
        write(TheUnit,'(A,F8.3,A)') "# m(stop)=",m_STop *100d0, " GeV"
      if( XTOPDECAYS.eq.3 ) then
        write(TheUnit,'(A,F8.3,A)') "# m(chi)=",m_Chi *100d0, " GeV"
        write(TheUnit,"(A,F10.6,A)") "# Gamma_STop(LO) =",Ga_STop(0)*100d0," GeV"
        write(TheUnit,"(A,F10.6,A)") "# Gamma_STop(NLO)=",(Ga_STop(0)+Ga_STop(1))*100d0," GeV"
      endif
    endif
    if( AlgoType.eq.1 ) then
        write(TheUnit,"(A,A)") "# Jet Algorithm= kT"
    elseif( AlgoType.eq.-1 ) then
        write(TheUnit,"(A,A)") "# Jet Algorithm= anti kT"
    else
        write(TheUnit,"(A)") "# Jet Algorithm= UNKNOWN"
    endif
    if( RecombPrescr.eq.0 ) then
        write(TheUnit,"(A,A)") "# Recombination scheme= 4-vector addition"
    elseif( RecombPrescr.eq.1 ) then
        write(TheUnit,"(A,A)") "# Recombination scheme= Ellis-Soper"
    else
        write(TheUnit,"(A)") "# Recombination scheme= UNKNOWN"
    endif

    if(HelSampling) then
       write(TheUnit,"(A)") "# helicity sampling"
    else
       write(TheUnit,"(A)") "# no helicity sampling"
    endif

    if (Correction .eq. 0 .and. LO_ReWeighting) then
       write(TheUnit,"(A)") "# Reweighting LO matrix elements"
    endif

   write(TheUnit,'(A,F8.3)') "# cuts:"
   write(TheUnit,'(A,F8.3)') "# pT_jet_cut= ",pT_jet_cut*100d0
   write(TheUnit,'(A,F8.3)') "# pT_hardestjet_cut= ",pT_hardestjet_cut*100d0
   write(TheUnit,'(A,F8.3)') "# eta_jet_cut= ",eta_jet_cut
   write(TheUnit,'(A,F8.3)') "# eta_sepa_cut= ",eta_sepa_cut
   write(TheUnit,'(A,F8.3)') "# pT_bjet_cut= ",pT_bjet_cut*100d0
   write(TheUnit,'(A,F8.3)') "# eta_bjet_cut= ",eta_bjet_cut
   write(TheUnit,'(A,F8.3)') "# Rsep_jet= ",Rsep_jet
   write(TheUnit,'(A,F8.3)') "# Rsep_lepjet= ",Rsep_lepjet
   write(TheUnit,'(A,F8.3)') "# Rsep_leplep= ",Rsep_leplep
   write(TheUnit,'(A,F8.3)') "# pT_lep_cut= ",pT_lep_cut*100d0
   write(TheUnit,'(A,F8.3)') "# eta_lep_cut= ",eta_lep_cut
   write(TheUnit,'(A,F8.3)') "# pT_miss_cut= ",pT_miss_cut*100d0
   write(TheUnit,'(A,F8.3)') "# MInv_jets_cut= ",MInv_jets_cut*100d0
   write(TheUnit,'(A,F8.3)') "# HT_cut= ",HT_cut*100d0
   write(TheUnit,'(A,F8.3)') "# pt_photon_cut= ",pt_pho_cut*100d0
   write(TheUnit,'(A,F8.3)') "# pt_photon_max= ",pt_pho_max*100d0
   write(TheUnit,'(A,F8.3)') "# eta_photon_cut= ",eta_pho_cut
   write(TheUnit,'(A,F8.3)') "# Rsep_photonjet= ",Rsep_Pj
   write(TheUnit,'(A,F8.3)') "# Rsep_photonbjet= ",Rsep_Pbj
   write(TheUnit,'(A,F8.3)') "# Rsep_photonlepton= ",Rsep_Plep
   write(TheUnit,'(A,F8.3)') "# MZ_window=",MZ_window*100d0


   write(TheUnit,'(A)') "#"

   write(TheUnit,"(A,I15)") "# VegasSeed=",VegasSeed
   write(TheUnit,"(A,I15)") "# VegasIt0 =",VegasIt0
   write(TheUnit,"(A,I15)") "# VegasNc0 =",VegasNc0
   write(TheUnit,"(A,I15)") "# VegasIt1 =",VegasIt1
   write(TheUnit,"(A,I15)") "# VegasNc1 =",VegasNc1
   write(TheUnit,"(A)") "# Histo file:        "//trim(HistoFile)//'.dat'
   write(TheUnit,"(A)") "# Vegas status file: "//trim(HistoFile)//'.status'
   write(TheUnit,"(A)") "# Histo status file: "//trim(HistoFile)//'.tmp_histo'


END SUBROUTINE




!DEC$ IF(_UseMPIVegas .EQ.0)
SUBROUTINE StartVegas(VG_Result,VG_Error,VG_Chi2)
use ModMisc
use ModCrossSection_TTB
use ModCrossSection_TTBJ
use ModCrossSection_TTBP
use ModCrossSection_TTBP_anomcoupl
use ModCrossSection_TTBZ
use ModCrossSection_TTBH
use ModCrossSection_TH
use ModCrossSection_TTBETmiss
use ModCrossSection_ZprimeTTB
use ModCrossSection_eeTTB
use ModKinematics
use ModParameters
implicit none
include "vegas_common.f"
real(8) :: VG_Result,VG_Error,VG_Chi2
logical :: warmup


if( GridIO.eq.-1 ) then
  readin=.false.
  writeout=.true.
  outgridfile=GridFile(1:72)
elseif( GridIO.eq.+1 ) then
  readin=.true.
  writeout=.false.
  ingridfile=GridFile(1:72)
elseif( GridIO.eq.+2 ) then
  FirstLOThenVI = .true.
else
  readin=.false.
  writeout=.false.
endif


VegasMxDim=mxdim

if( VegasIt0.eq.0 .OR. VegasNc0.eq.0 ) then
   warmup = .false.
   itmx = VegasIt1
   ncall= VegasNc1
else
   itmx = VegasIt0
   ncall= VegasNc0
   warmup = .true.
endif

IF( MASTERPROCESS.EQ.0 ) THEN
IF( CORRECTION   .EQ.1 ) THEN
  call vegas(EvalCS_1L_gggggg,VG_Result,VG_Error,VG_Chi2)
ENDIF
ENDIF


IF( MASTERPROCESS.EQ.1 ) THEN
IF( CORRECTION.LE.1 .AND. PROCESS.EQ.1 .AND. TOPDECAYS.NE.101) THEN
  call vegas(EvalCS_1L_ttbgg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_1L_ttbgg,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.LE.1 .AND. PROCESS.EQ.1 .AND. TOPDECAYS.EQ.101) THEN! this is experimental: ttbar off-shell production at LO
  ndim=14
  call vegas(EvalCS_LO_bbbWWgg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_LO_bbbWWgg,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.LE.1 .AND. PROCESS.EQ.21 ) THEN
  call vegas(EvalCS_DKP_1L_ttbgg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_DKP_1L_ttbgg,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.LE.1 .AND. PROCESS.EQ.33 ) THEN
  call vegas(EvalCS_DKJ_1L_ttbgg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_DKJ_1L_ttbgg,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.0 .AND. PROCESS.EQ.41 ) THEN
  call vegas(EvalCS_1L_HtHtbgg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_1L_HtHtbgg,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.3 .AND. PROCESS.EQ.5 ) THEN
  call vegas(EvalCS_1L_ttbgg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_1L_ttbgg,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.3 .AND. PROCESS.EQ.45 ) THEN
  call vegas(EvalCS_1L_HtHtbgg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_1L_HtHtbgg,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.3 .AND. PROCESS.EQ.29 ) THEN
  call vegas(EvalCS_DKP_1L_ttbgg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_DKP_1L_ttbgg,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.3 .AND. PROCESS.EQ.37 ) THEN
  call vegas(EvalCS_DKJ_1L_ttbgg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_DKJ_1L_ttbgg,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.4 .AND. PROCESS.EQ.1 ) THEN
  if( TOPDECAYS.GT.0 ) call vegas(EvalCS_NLODK_ttb,     VG_Result,VG_Error,VG_Chi2)
  if( TOPDECAYS.LT.0 ) call vegas(EvalCS_NLODK_ttb_noSC,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   if( TOPDECAYS.GT.0 ) call vegas1(EvalCS_NLODK_ttb,     VG_Result,VG_Error,VG_Chi2)
   if( TOPDECAYS.LT.0 ) call vegas1(EvalCS_NLODK_ttb_noSC,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.4 .AND. PROCESS.EQ.21 ) THEN
  call vegas(EvalCS_NLODKP_ttb,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_NLODKP_ttb,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.4 .AND. PROCESS.EQ.33 ) THEN
  call vegas(EvalCS_1LDKJ_ttb,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_1LDKJ_ttb,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.4 .AND. PROCESS.EQ.41 ) THEN
  call vegas(EvalCS_DKJ_1L_HtHtbgg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call vegas1(EvalCS_DKJ_1L_HtHtbgg,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.5 .AND. PROCESS.EQ.1 ) THEN
  if( TOPDECAYS.GT.0 ) call vegas(EvalCS_NLODK_ttb,     VG_Result,VG_Error,VG_Chi2)
  if( TOPDECAYS.LT.0 ) call vegas(EvalCS_NLODK_ttb_noSC,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   if( TOPDECAYS.GT.0 ) call vegas1(EvalCS_NLODK_ttb,     VG_Result,VG_Error,VG_Chi2)
   if( TOPDECAYS.LT.0 ) call vegas1(EvalCS_NLODK_ttb_noSC,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.5 .AND. PROCESS.EQ.21 ) THEN
  call vegas(EvalCS_NLODKP_ttb,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_NLODKP_ttb,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.5 .AND. PROCESS.EQ.33 ) THEN
  call vegas(EvalCS_REDKJ_ttb,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_REDKJ_ttb,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.5 .AND. PROCESS.EQ.41 ) THEN
  call vegas(EvalCS_DKJ_Real_HtHtbgg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call vegas1(EvalCS_DKJ_Real_HtHtbgg,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF




IF( MASTERPROCESS.EQ.2 ) THEN
IF( CORRECTION.LE.1 .AND. PROCESS.EQ.2 ) THEN
        call vegas(EvalCS_1L_ttbqqb,VG_Result,VG_Error,VG_Chi2)
        if( warmup ) then
        itmx = VegasIt1
        ncall= VegasNc1
        call InitHisto()
        call vegas1(EvalCS_1L_ttbqqb,VG_Result,VG_Error,VG_Chi2)
        endif
ELSEIF( CORRECTION.LE.1 .AND. PROCESS.EQ.23 ) THEN
        call vegas(EvalCS_DKP_1L_ttbqqb,VG_Result,VG_Error,VG_Chi2)
        if( warmup ) then
        itmx = VegasIt1
        ncall= VegasNc1
        call InitHisto()
        call vegas1(EvalCS_DKP_1L_ttbqqb,VG_Result,VG_Error,VG_Chi2)
        endif
ELSEIF( CORRECTION.LE.1 .AND. PROCESS.EQ.34 ) THEN
        call vegas(EvalCS_DKJ_1L_ttbqqb,VG_Result,VG_Error,VG_Chi2)
        if( warmup ) then
        itmx = VegasIt1
        ncall= VegasNc1
        call InitHisto()
        call vegas1(EvalCS_DKJ_1L_ttbqqb,VG_Result,VG_Error,VG_Chi2)
        endif
ELSEIF( CORRECTION.EQ.0 .AND. PROCESS.EQ.42 ) THEN
        call vegas(EvalCS_1L_HtHtbqqb,VG_Result,VG_Error,VG_Chi2)
        if( warmup ) then
        itmx = VegasIt1
        ncall= VegasNc1
        call InitHisto()
        call vegas1(EvalCS_1L_HtHtbqqb,VG_Result,VG_Error,VG_Chi2)
        endif
ELSEIF( CORRECTION.EQ.3 .AND. PROCESS.LE.6 ) THEN
        call vegas(EvalCS_1L_ttbqqb,VG_Result,VG_Error,VG_Chi2)
        if( warmup ) then
        itmx = VegasIt1
        ncall= VegasNc1
        call InitHisto()
        call vegas1(EvalCS_1L_ttbqqb,VG_Result,VG_Error,VG_Chi2)
        endif
ELSEIF( CORRECTION.EQ.3 .AND. (PROCESS.LE.43 .OR. PROCESS.LE.44 .OR. PROCESS.LE.46) ) THEN
        call vegas(EvalCS_1L_HtHtbqqb,VG_Result,VG_Error,VG_Chi2)
        if( warmup ) then
        itmx = VegasIt1
        ncall= VegasNc1
        call InitHisto()
        call vegas1(EvalCS_1L_HtHtbqqb,VG_Result,VG_Error,VG_Chi2)
        endif
ELSEIF( CORRECTION.EQ.3 .AND. (PROCESS.EQ.25.OR.PROCESS.EQ.27.OR.PROCESS.EQ.31) ) THEN
        call vegas(EvalCS_DKP_1L_ttbqqb,VG_Result,VG_Error,VG_Chi2)
        if( warmup ) then
        itmx = VegasIt1
        ncall= VegasNc1
        call InitHisto()
        call vegas1(EvalCS_DKP_1L_ttbqqb,VG_Result,VG_Error,VG_Chi2)
        endif
ELSEIF( CORRECTION.EQ.3 .AND. (PROCESS.EQ.35.OR.PROCESS.EQ.36.OR.PROCESS.EQ.38) ) THEN
        call vegas(EvalCS_DKJ_1L_ttbqqb,VG_Result,VG_Error,VG_Chi2)
        if( warmup ) then
        itmx = VegasIt1
        ncall= VegasNc1
        call InitHisto()
        call vegas1(EvalCS_DKJ_1L_ttbqqb,VG_Result,VG_Error,VG_Chi2)
        endif
ELSEIF( CORRECTION.EQ.4 .AND. PROCESS.EQ.2 ) THEN
  if( TOPDECAYS.GT.0 ) call vegas(EvalCS_NLODK_ttb,     VG_Result,VG_Error,VG_Chi2)
  if( TOPDECAYS.LT.0 ) call vegas(EvalCS_NLODK_ttb_noSC,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   if( TOPDECAYS.GT.0 ) call vegas1(EvalCS_NLODK_ttb,     VG_Result,VG_Error,VG_Chi2)
   if( TOPDECAYS.LT.0 ) call vegas1(EvalCS_NLODK_ttb_noSC,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.4 .AND. PROCESS.EQ.23 ) THEN
  call vegas(EvalCS_NLODKP_ttb,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_NLODKP_ttb,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.4 .AND. PROCESS.EQ.34 ) THEN
  call vegas(EvalCS_1LDKJ_ttb,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_1LDKJ_ttb,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.4 .AND. PROCESS.EQ.42 ) THEN
  call vegas(EvalCS_DKJ_1L_HtHtbqqb,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call vegas1(EvalCS_DKJ_1L_HtHtbqqb,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.5 .AND. PROCESS.EQ.2 ) THEN
  if( TOPDECAYS.GT.0 ) call vegas(EvalCS_NLODK_ttb,     VG_Result,VG_Error,VG_Chi2)
  if( TOPDECAYS.LT.0 ) call vegas(EvalCS_NLODK_ttb_noSC,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   if( TOPDECAYS.GT.0 ) call vegas1(EvalCS_NLODK_ttb,     VG_Result,VG_Error,VG_Chi2)
   if( TOPDECAYS.LT.0 ) call vegas1(EvalCS_NLODK_ttb_noSC,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.5 .AND. PROCESS.EQ.23 ) THEN
  call vegas(EvalCS_NLODKP_ttb,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_NLODKP_ttb,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.5 .AND. PROCESS.EQ.34 ) THEN
  call vegas(EvalCS_REDKJ_ttb,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_REDKJ_ttb,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.5 .AND. PROCESS.EQ.42 ) THEN
  call vegas(EvalCS_DKJ_Real_HtHtbqqb,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call vegas1(EvalCS_DKJ_Real_HtHtbqqb,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF





IF( MASTERPROCESS.EQ.3 ) THEN
IF( CORRECTION   .LE.1 ) THEN
  call vegas(EvalCS_1L_ttbggg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_1L_ttbggg,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.2 .AND. PROCESS.EQ.5) THEN
  call vegas(EvalCS_Real_ttbggg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_Real_ttbggg,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.2 .AND. PROCESS.EQ.29) THEN
  call vegas(EvalCS_DKP_Real_ttbggg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_DKP_Real_ttbggg,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.2 .AND. PROCESS.EQ.37) THEN
  call vegas(EvalCS_DKJ_Real_ttbggg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_DKJ_Real_ttbggg,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.2 .AND. PROCESS.EQ.45) THEN
  m_Top = m_SMTop! restoring m_Top after reset in mod_Process.f90
  call vegas(EvalCS_Real_HtHtbggg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_Real_HtHtbggg,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION .EQ.3 ) THEN
  call vegas(EvalCS_1L_ttbggg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_1L_ttbggg,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION .EQ.4 ) THEN
  call vegas(EvalCS_1LDK_ttbggg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_1LDK_ttbggg,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF




IF( MASTERPROCESS.EQ.4 ) THEN
IF( CORRECTION.EQ.0 ) THEN
  call vegas(EvalCS_1L_ttbqqbg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_1L_ttbqqbg,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.2 .AND. (PROCESS.EQ.3 .OR. PROCESS.EQ.4 .OR. PROCESS.EQ.6) ) THEN

  call vegas(EvalCS_Real_ttbqqbg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_Real_ttbqqbg,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.2 .AND. (PROCESS.EQ.25 .OR. PROCESS.EQ.27 .OR. PROCESS.EQ.31) ) THEN
  call vegas(EvalCS_DKP_Real_ttbqqbg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_DKP_Real_ttbqqbg,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.2 .AND. (PROCESS.EQ.35 .OR. PROCESS.EQ.36 .OR. PROCESS.EQ.38) ) THEN
  call vegas(EvalCS_DKJ_Real_ttbqqbg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_DKJ_Real_ttbqqbg,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.2 .AND. (PROCESS.EQ.43 .OR. PROCESS.EQ.44 .OR. PROCESS.EQ.46) ) THEN
  m_Top = m_SMTop! restoring m_Top after reset in mod_Process.f90
  call vegas(EvalCS_Real_HtHtbqqbg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_Real_HtHtbqqbg,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.1 ) THEN
  call vegas(EvalCS_1L_ttbqqbg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_1L_ttbqqbg,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.3 ) THEN
  call vegas(EvalCS_1L_ttbqqbg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_1L_ttbqqbg,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.4 ) THEN
  call vegas(EvalCS_1LDK_ttbqqbg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_1LDK_ttbqqbg,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF



IF( MASTERPROCESS.EQ.5 ) THEN
IF( CORRECTION   .EQ.2 ) THEN
  call vegas(EvalCS_Real_ttbgggg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_Real_ttbgggg,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF



IF( MASTERPROCESS.EQ.6 ) THEN
IF( CORRECTION   .EQ.2 ) THEN
  call vegas(EvalCS_Real_ttbqqbgg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_Real_ttbqqbgg,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF



IF( MASTERPROCESS.EQ.7 ) THEN
IF( CORRECTION   .EQ.2 ) THEN
  call vegas(EvalCS_Real_ttbqqbqqb,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_Real_ttbqqbqqb,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF




IF( MASTERPROCESS.EQ.8 ) THEN
IF( CORRECTION   .LE.1 ) THEN
!  if( TTBPhoton_SMonly ) then 
      call vegas(EvalCS_1L_ttbggp,VG_Result,VG_Error,VG_Chi2)
!  else 
!      call vegas(EvalCS_anomcoupl_1L_ttbggp,VG_Result,VG_Error,VG_Chi2)
!  endif
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
!   if( TTBPhoton_SMonly ) then 
      call vegas1(EvalCS_1L_ttbggp,VG_Result,VG_Error,VG_Chi2)
!  else
!      call vegas1(EvalCS_anomcoupl_1L_ttbggp,VG_Result,VG_Error,VG_Chi2)
!  endif
  endif
ELSEIF( CORRECTION.EQ.3 ) THEN
  if( TTBPhoton_SMonly ) then 
      call vegas(EvalCS_1L_ttbggp,VG_Result,VG_Error,VG_Chi2)
  else
      call vegas(EvalCS_anomcoupl_1L_ttbggp,VG_Result,VG_Error,VG_Chi2)
  endif
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   if( TTBPhoton_SMonly ) then 
      call vegas1(EvalCS_1L_ttbggp,VG_Result,VG_Error,VG_Chi2)
  else
      call vegas1(EvalCS_anomcoupl_1L_ttbggp,VG_Result,VG_Error,VG_Chi2)
  endif
  endif
ELSEIF( CORRECTION.EQ.4 ) THEN
  if( TTBPhoton_SMonly ) then 
      call vegas(EvalCS_NLODK_ttbp,VG_Result,VG_Error,VG_Chi2)
  else
      call vegas(EvalCS_anomcoupl_NLODK_ttbp,VG_Result,VG_Error,VG_Chi2)
  endif
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   if( TTBPhoton_SMonly ) then 
      call vegas1(EvalCS_NLODK_ttbp,VG_Result,VG_Error,VG_Chi2)
  else
      call vegas1(EvalCS_anomcoupl_NLODK_ttbp,VG_Result,VG_Error,VG_Chi2)
  endif
  endif
ELSEIF( CORRECTION.EQ.5 ) THEN
  if( TTBPhoton_SMonly ) then 
     call vegas(EvalCS_NLODK_ttbp,VG_Result,VG_Error,VG_Chi2)
  else
     call vegas(EvalCS_anomcoupl_NLODK_ttbp,VG_Result,VG_Error,VG_Chi2)
  endif
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   if( TTBPhoton_SMonly ) then 
      call vegas1(EvalCS_NLODK_ttbp,VG_Result,VG_Error,VG_Chi2)
  else
      call vegas1(EvalCS_anomcoupl_NLODK_ttbp,VG_Result,VG_Error,VG_Chi2)
  endif
  endif
ELSE
  call Error("this correction is not available")
ENDIF
ENDIF


IF( MASTERPROCESS.EQ.9 ) THEN
IF( CORRECTION   .LE.1 ) THEN
  if( TTBPhoton_SMonly ) then 
      call vegas(EvalCS_1L_ttbqqbp,VG_Result,VG_Error,VG_Chi2)
  else
      call vegas(EvalCS_anomcoupl_1L_ttbqqbp,VG_Result,VG_Error,VG_Chi2)
  endif
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   if( TTBPhoton_SMonly ) then 
      call vegas1(EvalCS_1L_ttbqqbp,VG_Result,VG_Error,VG_Chi2)
  else
      call vegas1(EvalCS_anomcoupl_1L_ttbqqbp,VG_Result,VG_Error,VG_Chi2)
  endif
  endif
ELSEIF( CORRECTION.EQ.3 ) THEN
  if( TTBPhoton_SMonly ) then 
      call vegas(EvalCS_1L_ttbqqbp,VG_Result,VG_Error,VG_Chi2)
  else
      call vegas(EvalCS_anomcoupl_1L_ttbqqbp,VG_Result,VG_Error,VG_Chi2)
  endif
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   if( TTBPhoton_SMonly ) then 
      call vegas1(EvalCS_1L_ttbqqbp,VG_Result,VG_Error,VG_Chi2)
  else
      call vegas1(EvalCS_anomcoupl_1L_ttbqqbp,VG_Result,VG_Error,VG_Chi2)
  endif
  endif
ELSEIF( CORRECTION.EQ.4 ) THEN
  if( TTBPhoton_SMonly ) then 
      call vegas(EvalCS_NLODK_ttbp,VG_Result,VG_Error,VG_Chi2)
  else
      call vegas(EvalCS_anomcoupl_NLODK_ttbp,VG_Result,VG_Error,VG_Chi2)
  endif
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   if( TTBPhoton_SMonly ) then 
      call vegas1(EvalCS_NLODK_ttbp,VG_Result,VG_Error,VG_Chi2)
  else
      call vegas1(EvalCS_anomcoupl_NLODK_ttbp,VG_Result,VG_Error,VG_Chi2)
  endif
  endif
ELSEIF( CORRECTION.EQ.5 ) THEN
  if( TTBPhoton_SMonly ) then 
      call vegas(EvalCS_NLODK_ttbp,VG_Result,VG_Error,VG_Chi2)
  else
      call vegas(EvalCS_anomcoupl_NLODK_ttbp,VG_Result,VG_Error,VG_Chi2)
  endif
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   if( TTBPhoton_SMonly ) then 
      call vegas1(EvalCS_NLODK_ttbp,VG_Result,VG_Error,VG_Chi2)
  else
      call vegas1(EvalCS_anomcoupl_NLODK_ttbp,VG_Result,VG_Error,VG_Chi2)
  endif
  endif
ENDIF
ENDIF



IF( MASTERPROCESS.EQ.10 ) THEN
IF( CORRECTION.EQ.2 ) THEN
  if( TTBPhoton_SMonly ) then 
      call vegas(EvalCS_Real_ttbgggp,VG_Result,VG_Error,VG_Chi2)
  else
      call vegas(EvalCS_anomcoupl_Real_ttbgggp,VG_Result,VG_Error,VG_Chi2)
  endif
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   if( TTBPhoton_SMonly ) then 
      call vegas1(EvalCS_Real_ttbgggp,VG_Result,VG_Error,VG_Chi2)
  else
      call vegas1(EvalCS_anomcoupl_Real_ttbgggp,VG_Result,VG_Error,VG_Chi2)
  endif
  endif
ENDIF
ENDIF




IF( MASTERPROCESS.EQ.11 ) THEN
IF( CORRECTION.EQ.2 ) THEN
  if( TTBPhoton_SMonly ) then 
      call vegas(EvalCS_Real_ttbqqbgp,VG_Result,VG_Error,VG_Chi2)
  else
      call vegas(EvalCS_anomcoupl_Real_ttbqqbgp,VG_Result,VG_Error,VG_Chi2)
  endif
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   if( TTBPhoton_SMonly ) then 
      call vegas1(EvalCS_Real_ttbqqbgp,VG_Result,VG_Error,VG_Chi2)
  else
      call vegas1(EvalCS_anomcoupl_Real_ttbqqbgp,VG_Result,VG_Error,VG_Chi2)
  endif
  endif
ENDIF
ENDIF




IF( MASTERPROCESS.EQ.12 ) THEN
IF( CORRECTION.LE.1 .AND. PROCESS.EQ.51 ) THEN
  call vegas(EvalCS_1L_ststbgg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call vegas1(EvalCS_1L_ststbgg,VG_Result,VG_Error,VG_Chi2)
  endif

ELSEIF( CORRECTION.EQ.3 .AND. PROCESS.EQ.55 ) THEN
  call vegas(EvalCS_1L_ststbgg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call vegas1(EvalCS_1L_ststbgg,VG_Result,VG_Error,VG_Chi2)
  endif


ELSEIF( CORRECTION.EQ.4 .AND. PROCESS.EQ.51 ) THEN
  call vegas(EvalCS_DKJ_1L_ststbgg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call vegas1(EvalCS_DKJ_1L_ststbgg,VG_Result,VG_Error,VG_Chi2)
  endif



ELSEIF( CORRECTION.EQ.5 .AND. PROCESS.EQ.51 ) THEN
  call vegas(EvalCS_DKJ_Real_ststbgg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call vegas1(EvalCS_DKJ_Real_ststbgg,VG_Result,VG_Error,VG_Chi2)
  endif

ENDIF
ENDIF




IF( MASTERPROCESS.EQ.13 ) THEN
IF( CORRECTION.LE.1 .AND. PROCESS.EQ.52 ) THEN
  call vegas(EvalCS_1L_ststbqqb,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call vegas1(EvalCS_1L_ststbqqb,VG_Result,VG_Error,VG_Chi2)
  endif

ELSEIF( CORRECTION.EQ.3 .AND. (PROCESS.EQ.56 .OR. PROCESS.EQ.53 .OR. PROCESS.EQ.54 ) ) THEN
  call vegas(EvalCS_1L_ststbqqb,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call vegas1(EvalCS_1L_ststbqqb,VG_Result,VG_Error,VG_Chi2)
  endif


ELSEIF( CORRECTION.EQ.4 .AND. PROCESS.EQ.52 ) THEN
  call vegas(EvalCS_DKJ_1L_ststbqqb,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call vegas1(EvalCS_DKJ_1L_ststbqqb,VG_Result,VG_Error,VG_Chi2)
  endif



ELSEIF( CORRECTION.EQ.5 .AND. PROCESS.EQ.52 ) THEN
  call vegas(EvalCS_DKJ_Real_ststbqqb,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call vegas1(EvalCS_DKJ_Real_ststbqqb,VG_Result,VG_Error,VG_Chi2)
  endif



ENDIF
ENDIF




IF( MASTERPROCESS.EQ.14 ) THEN
IF( CORRECTION.EQ.2 .AND. PROCESS.EQ.55 ) THEN
  call vegas(EvalCS_Real_ststbggg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call vegas1(EvalCS_Real_ststbggg,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF





IF( MASTERPROCESS.EQ.15 ) THEN
IF( CORRECTION.EQ.2 .AND. (PROCESS.EQ.53 .OR. PROCESS.EQ.54 .OR. PROCESS.EQ.56 ) ) THEN
  call vegas(EvalCS_Real_ststbqqbg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call vegas1(EvalCS_Real_ststbqqbg,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF








IF( MASTERPROCESS.EQ.16 ) THEN
IF( CORRECTION.LE.1 .AND. (PROCESS.EQ.56 .OR. PROCESS.EQ.59) ) THEN
  call vegas(EvalCS_1L_ststbgggg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call vegas1(EvalCS_1L_ststbgggg,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF



IF( MASTERPROCESS.EQ.17 ) THEN
IF( CORRECTION   .EQ.0 ) THEN
   if (Process .ge. 71 .and. Process .le. 79) then
      call vegas(EvalCS_1L_ttbggZ,VG_Result,VG_Error,VG_Chi2)
   elseif (Process .ge. 81 .and. Process .le. 89) then
      call vegas(EvalCS_anomcoupl_1L_ttbggp,VG_Result,VG_Error,VG_Chi2)
   endif
      
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   if (Process .ge. 71 .and. Process .le. 79) then
      call vegas1(EvalCS_1L_ttbggZ,VG_Result,VG_Error,VG_Chi2)
   elseif (Process .ge. 81 .and. Process .le. 89) then
      call vegas(EvalCS_anomcoupl_1L_ttbggp,VG_Result,VG_Error,VG_Chi2)
   endif
  endif

ELSEIF( CORRECTION   .EQ.1 ) THEN
  if( FirstLOThenVI ) then
      CORRECTION=0
      if (Process .ge. 71 .and. Process .le. 79) then
         call vegas(EvalCS_1L_ttbggZ,VG_Result,VG_Error,VG_Chi2)
      elseif (Process .ge. 81 .and. Process .le. 89) then
         call vegas(EvalCS_anomcoupl_1L_ttbggp,VG_Result,VG_Error,VG_Chi2)
      endif
      if( warmup ) then
        itmx = VegasIt1
        ncall= VegasNc0
        if (Process .ge. 71 .and. Process .le. 79) then
           call vegas1(EvalCS_1L_ttbggZ,VG_Result,VG_Error,VG_Chi2)
        elseif (Process .ge. 81 .and. Process .le. 89) then
           call vegas(EvalCS_anomcoupl_1L_ttbggp,VG_Result,VG_Error,VG_Chi2)
        endif
      endif

      call InitHisto()
      EvalCounter = 0
      itmx = 1
      ncall= VegasNc1
      CORRECTION=1
      if (Process .ge. 71 .and. Process .le. 79) then
         call vegas1(EvalCS_1L_ttbggZ,VG_Result,VG_Error,VG_Chi2)
      elseif (Process .ge. 81 .and. Process .le. 89) then
         call vegas(EvalCS_anomcoupl_1L_ttbggp,VG_Result,VG_Error,VG_Chi2)
      endif
  else
      if (Process .ge. 71 .and. Process .le. 79) then
         call vegas(EvalCS_1L_ttbggZ,VG_Result,VG_Error,VG_Chi2)
      elseif (Process .ge. 81 .and. Process .le. 89) then
         call vegas(EvalCS_anomcoupl_1L_ttbggp,VG_Result,VG_Error,VG_Chi2)
      endif

      if( warmup ) then
        itmx = VegasIt1
        ncall= VegasNc1
        call InitHisto()
        if (Process .ge. 71 .and. Process .le. 79) then
           call vegas1(EvalCS_1L_ttbggZ,VG_Result,VG_Error,VG_Chi2)
        elseif (Process .ge. 81 .and. Process .le. 89) then
           call vegas(EvalCS_anomcoupl_1L_ttbggp,VG_Result,VG_Error,VG_Chi2)
        endif
      endif
   endif

ELSEIF( CORRECTION.EQ.3 ) THEN
  call vegas(EvalCS_1L_ttbggZ,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_1L_ttbggZ,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.4 ) THEN
  call vegas(EvalCS_NLODK_ttbZ,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_NLODK_ttbZ,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.5 ) THEN
  call vegas(EvalCS_NLODK_ttbZ,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_NLODK_ttbZ,VG_Result,VG_Error,VG_Chi2)
  endif
ELSE
  call Error("this correction is not available")
ENDIF
ENDIF


IF( MASTERPROCESS.EQ.18 ) THEN
IF( CORRECTION   .EQ.0 ) THEN
   if (Process .ge. 71 .and. Process .le. 79) then
      call vegas(EvalCS_1L_ttbqqbZ,VG_Result,VG_Error,VG_Chi2)
   elseif (Process .ge. 81 .and. Process .le. 89) then
      call vegas(EvalCS_anomcoupl_1L_ttbqqbp,VG_Result,VG_Error,VG_Chi2)
   endif
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   if (Process .ge. 71 .and. Process .le. 79) then
      call vegas1(EvalCS_1L_ttbqqbZ,VG_Result,VG_Error,VG_Chi2)
   elseif (Process .ge. 81 .and. Process .le. 89) then
      call vegas1(EvalCS_anomcoupl_1L_ttbqqbp,VG_Result,VG_Error,VG_Chi2)
   endif
  endif

ELSEIF( CORRECTION .EQ.1 ) THEN
  if( FirstLOThenVI ) then
      CORRECTION=0
      if (Process .ge. 71 .and. Process .le. 79) then
         call vegas(EvalCS_1L_ttbqqbZ,VG_Result,VG_Error,VG_Chi2)
      elseif (Process .ge. 81 .and. Process .le. 89) then
         call vegas(EvalCS_anomcoupl_1L_ttbqqbp,VG_Result,VG_Error,VG_Chi2)
      endif
      if( warmup ) then
        itmx = VegasIt1
        ncall= VegasNc0
        if (Process .ge. 71 .and. Process .le. 79) then
           call vegas1(EvalCS_1L_ttbqqbZ,VG_Result,VG_Error,VG_Chi2)
        elseif (Process .ge. 81 .and. Process .le. 89) then
           call vegas1(EvalCS_anomcoupl_1L_ttbqqbp,VG_Result,VG_Error,VG_Chi2)
        endif
      endif

      call InitHisto()
      EvalCounter = 0
      itmx = 1
      ncall= VegasNc1
      CORRECTION=1
      if (Process .ge. 71 .and. Process .le. 79) then
         call vegas1(EvalCS_1L_ttbqqbZ,VG_Result,VG_Error,VG_Chi2)
      elseif (Process .ge. 81 .and. Process .le. 89) then
         call vegas1(EvalCS_anomcoupl_1L_ttbqqbp,VG_Result,VG_Error,VG_Chi2)
      endif
  else
     if (Process .ge. 71 .and. Process .le. 79) then
        call vegas(EvalCS_1L_ttbqqbZ,VG_Result,VG_Error,VG_Chi2)
     elseif (Process .ge. 81 .and. Process .le. 89) then
        call vegas(EvalCS_anomcoupl_1L_ttbqqbp,VG_Result,VG_Error,VG_Chi2)
     endif
      if( warmup ) then
        itmx = VegasIt1
        ncall= VegasNc1
        call InitHisto()
        if (Process .ge. 71 .and. Process .le. 79) then
           call vegas1(EvalCS_1L_ttbqqbZ,VG_Result,VG_Error,VG_Chi2)
        elseif (Process .ge. 81 .and. Process .le. 89) then
           call vegas1(EvalCS_anomcoupl_1L_ttbqqbp,VG_Result,VG_Error,VG_Chi2)
        endif
      endif
  endif


ELSEIF( CORRECTION.EQ.3 ) THEN
  call vegas(EvalCS_1L_ttbqqbZ,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_1L_ttbqqbZ,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.4 ) THEN
  call vegas(EvalCS_NLODK_ttbZ,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_NLODK_ttbZ,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.5 ) THEN
  call vegas(EvalCS_NLODK_ttbZ,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_NLODK_ttbZ,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF



IF( MASTERPROCESS.EQ.19 ) THEN

IF( CORRECTION.EQ.2 ) THEN
   if (Process .ge. 71 .and. Process .le. 79) then   
      call vegas(EvalCS_Real_ttbgggZ,VG_Result,VG_Error,VG_Chi2)
   elseif (Process .ge. 81 .and. Process .le. 89) then
      call vegas(EvalCS_anomcoupl_Real_ttbgggp,VG_Result,VG_Error,VG_Chi2)
   endif
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   if (Process .ge. 71 .and. Process .le. 79) then
      call vegas1(EvalCS_Real_ttbgggZ,VG_Result,VG_Error,VG_Chi2)
   elseif (Process .ge. 81 .and. Process .le. 89) then
      call vegas(EvalCS_anomcoupl_Real_ttbgggp,VG_Result,VG_Error,VG_Chi2)
   endif
  endif
ENDIF
ENDIF




IF( MASTERPROCESS.EQ.20 ) THEN
IF( CORRECTION.EQ.2 ) THEN
   if (Process .ge. 71 .and. Process .le. 79) then   
      call vegas(EvalCS_Real_ttbqqbgZ,VG_Result,VG_Error,VG_Chi2)
   elseif (Process .ge. 81 .and. Process .le. 89) then
      call vegas(EvalCS_anomcoupl_Real_ttbqqbgp,VG_Result,VG_Error,VG_Chi2)
   endif
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   if (Process .ge. 71 .and. Process .le. 79) then   
      call vegas1(EvalCS_Real_ttbqqbgZ,VG_Result,VG_Error,VG_Chi2)
   elseif (Process .ge. 81 .and. Process .le. 89) then
      call vegas(EvalCS_anomcoupl_Real_ttbqqbgp,VG_Result,VG_Error,VG_Chi2)
   endif
  endif
ENDIF
ENDIF



IF( MASTERPROCESS.EQ.21 ) THEN
IF( CORRECTION   .EQ.0 ) THEN
  call vegas(EvalCS_1L_ee_ttb,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_1L_ee_ttb,VG_Result,VG_Error,VG_Chi2)
  endif

ELSEIF( CORRECTION .EQ.1 ) THEN
  if( FirstLOThenVI ) then
      CORRECTION=0
      call vegas(EvalCS_1L_ee_ttb,VG_Result,VG_Error,VG_Chi2)
      if( warmup ) then
        itmx = VegasIt1
        ncall= VegasNc0
        call vegas1(EvalCS_1L_ee_ttb,VG_Result,VG_Error,VG_Chi2)
      endif

      call InitHisto()
      EvalCounter = 0
      itmx = 1
      ncall= VegasNc1
      CORRECTION=1
      call vegas1(EvalCS_1L_ee_ttb,VG_Result,VG_Error,VG_Chi2)
  else
      call vegas(EvalCS_1L_ee_ttb,VG_Result,VG_Error,VG_Chi2)
      if( warmup ) then
        itmx = VegasIt1
        ncall= VegasNc1
        call InitHisto()
        call vegas1(EvalCS_1L_ee_ttb,VG_Result,VG_Error,VG_Chi2)
      endif
  endif


ELSEIF( CORRECTION.EQ.3 ) THEN
  call vegas(EvalCS_1L_ee_ttb,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_1L_ee_ttb,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.4 ) THEN
  call vegas(EvalCS_NLODK_ee_ttb,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_NLODK_ee_ttb,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.5 ) THEN
  call vegas(EvalCS_NLODK_ee_ttb,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_NLODK_ee_ttb,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF

ENDIF




IF( MASTERPROCESS.EQ.22 ) THEN
IF( CORRECTION.EQ.2 ) THEN
  call vegas(EvalCS_Real_ee_ttbg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_Real_ee_ttbg,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF

ENDIF


IF( MASTERPROCESS.EQ.23 ) THEN
IF( CORRECTION   .EQ.0 ) THEN
  call vegas(EvalCS_1L_ttbggH,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_1L_ttbggH,VG_Result,VG_Error,VG_Chi2)
  endif

ELSEIF( CORRECTION   .EQ.1 ) THEN
  if( FirstLOThenVI ) then
      CORRECTION=0
      call vegas(EvalCS_1L_ttbggH,VG_Result,VG_Error,VG_Chi2)
      if( warmup ) then
        itmx = VegasIt1
        ncall= VegasNc0
        call vegas1(EvalCS_1L_ttbggH,VG_Result,VG_Error,VG_Chi2)
      endif

      call InitHisto()
      EvalCounter = 0
      itmx = 1
      ncall= VegasNc1
      CORRECTION=1
      call vegas1(EvalCS_1L_ttbggH,VG_Result,VG_Error,VG_Chi2)
  else
      call vegas(EvalCS_1L_ttbggH,VG_Result,VG_Error,VG_Chi2)
      if( warmup ) then
        itmx = VegasIt1
        ncall= VegasNc1
        call InitHisto()
        call vegas1(EvalCS_1L_ttbggH,VG_Result,VG_Error,VG_Chi2)
      endif
  endif

ELSEIF( CORRECTION.EQ.3 ) THEN
  call vegas(EvalCS_1L_ttbggH,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_1L_ttbggH,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.4 ) THEN
  call vegas(EvalCS_NLODK_ttbH,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_NLODK_ttbH,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.5 ) THEN
  call vegas(EvalCS_NLODK_ttbH,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_NLODK_ttbH,VG_Result,VG_Error,VG_Chi2)
  endif
ELSE
  call Error("this correction is not available")
ENDIF
ENDIF


IF( MASTERPROCESS.EQ.24 ) THEN
IF( CORRECTION   .EQ.0 ) THEN
  call vegas(EvalCS_1L_ttbqqbH,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_1L_ttbqqbH,VG_Result,VG_Error,VG_Chi2)
  endif

ELSEIF( CORRECTION .EQ.1 ) THEN
  if( FirstLOThenVI ) then
      CORRECTION=0
      call vegas(EvalCS_1L_ttbqqbH,VG_Result,VG_Error,VG_Chi2)
      if( warmup ) then
        itmx = VegasIt1
        ncall= VegasNc0
        call vegas1(EvalCS_1L_ttbqqbH,VG_Result,VG_Error,VG_Chi2)
      endif

      call InitHisto()
      EvalCounter = 0
      itmx = 1
      ncall= VegasNc1
      CORRECTION=1
      call vegas1(EvalCS_1L_ttbqqbH,VG_Result,VG_Error,VG_Chi2)
  else
      call vegas(EvalCS_1L_ttbqqbH,VG_Result,VG_Error,VG_Chi2)
      if( warmup ) then
        itmx = VegasIt1
        ncall= VegasNc1
        call InitHisto()
        call vegas1(EvalCS_1L_ttbqqbH,VG_Result,VG_Error,VG_Chi2)
      endif
  endif


ELSEIF( CORRECTION.EQ.3 ) THEN
  call vegas(EvalCS_1L_ttbqqbH,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_1L_ttbqqbH,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.4 ) THEN
  call vegas(EvalCS_NLODK_ttbH,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_NLODK_ttbH,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.5 ) THEN
  call vegas(EvalCS_NLODK_ttbH,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_NLODK_ttbH,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF



IF( MASTERPROCESS.EQ.25 ) THEN

IF( CORRECTION.EQ.2 ) THEN
  call vegas(EvalCS_Real_ttbgggH,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_Real_ttbgggH,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF




IF( MASTERPROCESS.EQ.26 ) THEN
IF( CORRECTION.EQ.2 ) THEN
  call vegas(EvalCS_Real_ttbqqbgH,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_Real_ttbqqbgH,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF





IF( MASTERPROCESS.EQ.31 ) THEN
   IF( CORRECTION.EQ.1 .AND. PROCESS.EQ.41 ) THEN
  call vegas(EvalCS_1L_HtHtbgg,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_1L_HtHtbgg,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF


IF( MASTERPROCESS.EQ.32 ) THEN
   IF( CORRECTION.EQ.1 .AND. PROCESS.EQ.42 ) THEN
  call vegas(EvalCS_1L_HtHtbqqb,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_1L_HtHtbqqb,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF


IF( MASTERPROCESS.EQ.41 .OR. MASTERPROCESS.EQ.42 ) THEN
IF( CORRECTION.EQ.0 .OR. CORRECTION.EQ.4 .OR. CORRECTION.EQ.5) THEN
  call vegas(EvalCS_StopWidth,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call vegas1(EvalCS_StopWidth,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF



IF( MASTERPROCESS.EQ.43 .OR. MASTERPROCESS.EQ.44 ) THEN
IF( CORRECTION.EQ.0 .OR. CORRECTION.EQ.4 .OR. CORRECTION.EQ.5) THEN
  call vegas(EvalCS_HTopWidth,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call vegas1(EvalCS_HTopWidth,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF


IF( MASTERPROCESS.EQ.62 ) THEN
IF( (CORRECTION.LE.1) .AND. PROCESS.EQ.62 ) THEN
   print *, 'LO / Virt Zprime'
   call qlinit()
!   call ltini ! looptools
   call vegas(EvalCS_1L_Zprime_ttbqqb,VG_Result,VG_Error,VG_Chi2)
   if( warmup ) then
      itmx = VegasIt1
      ncall= VegasNc1
      call InitHisto()
      call vegas1(EvalCS_1L_Zprime_ttbqqb,VG_Result,VG_Error,VG_Chi2)
   endif
ELSEIF ( CORRECTION.EQ.3 .AND. (PROCESS.EQ.63 .OR. PROCESS.EQ.64 .OR. PROCESS.EQ.66)) THEN
   print *, 'Zprime Int Dipoles'
   call qlinit()
!   call ltini ! looptools
   call vegas(EvalCS_1L_Zprime_ttbqqb,VG_Result,VG_Error,VG_Chi2)
   if( warmup ) then
      itmx = VegasIt1
      ncall= VegasNc1
      call InitHisto()
      call vegas1(EvalCS_1L_Zprime_ttbqqb,VG_Result,VG_Error,VG_Chi2)
   endif
ELSEIF( CORRECTION.EQ.4 .AND. PROCESS.EQ.62 ) THEN
   print *, 'Virtual in decay, qqb->Zprime->ttb'
   call vegas(EvalCS_NLODK_Zprime_ttb,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_NLODK_Zprime_ttb,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.5 .AND. PROCESS.EQ.62 ) THEN
   print *, 'Real in decay, qqb->Zprime->ttb'
   call vegas(EvalCS_NLODK_Zprime_ttb,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_NLODK_Zprime_ttb,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF

IF( MASTERPROCESS.EQ.63 ) THEN
IF( CORRECTION.EQ.2 .AND. (PROCESS.EQ.63 .OR. PROCESS.EQ.64 .OR. PROCESS.EQ.66 )) THEN
   print *, 'Real correction, qqb->Zprime->ttb'
  call vegas(EvalCS_Real_Zprime_ttbqqb,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call vegas1(EvalCS_Real_Zprime_ttbqqb,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF

IF ( MASTERPROCESS.EQ.2) THEN
IF ( CORRECTION.EQ.1 .AND. PROCESS.EQ.65 ) THEN
   call qlinit()
!   call ltini  ! looptools
   print *, "Gluon-Z' interference, virtual"
  call vegas(EvalCS_Virt_Zprime_Interf,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call vegas1(EvalCS_Virt_Zprime_Interf,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
IF ( CORRECTION.EQ.3 .AND. PROCESS.EQ.69 ) THEN
   call qlinit()
!   call ltini  ! looptools
   print *, "Gluon-Z' interference, integrated dipoles"
  call vegas(EvalCS_Virt_Zprime_Interf,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call vegas1(EvalCS_Virt_Zprime_Interf,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF

IF ( MASTERPROCESS.EQ.4) THEN
IF ( CORRECTION.EQ.2 .AND. PROCESS.EQ.67 ) THEN
   call qlinit()
!   call ltini ! looptools
   print *, "Gluon-Z' interference, real"
  call vegas(EvalCS_Real_Zprime_Interf,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call vegas1(EvalCS_Real_Zprime_Interf,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF ( CORRECTION.EQ.2 .AND. PROCESS.EQ.68 ) THEN
   call qlinit()
   print *, "Gluon-Z' interference, real"
  call vegas(EvalCS_Real_Zprime_Interf,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call vegas1(EvalCS_Real_Zprime_Interf,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF ( CORRECTION.EQ.2 .AND. PROCESS.EQ.69 ) THEN
   call qlinit()
   print *, "Gluon-Z' interference, real"
  call vegas(EvalCS_Real_Zprime_Interf,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call vegas1(EvalCS_Real_Zprime_Interf,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF



IF( MASTERPROCESS.EQ.73 ) THEN
IF( CORRECTION   .EQ.0 ) THEN
  call vegas(EvalCS_LO_tdubH,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_LO_tdubH,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF

IF( MASTERPROCESS.EQ.74 ) THEN
IF( CORRECTION   .EQ.0 ) THEN
  call vegas(EvalCS_LO_tbardubbarH,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call vegas1(EvalCS_LO_tbardubbarH,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF





return
END SUBROUTINE
!DEC$ ENDIF




!DEC$ IF(_UseMPIVegas .EQ.1)
SUBROUTINE StartPVegas(VG_Result,VG_Error,VG_Chi2)
use ModMisc
use ModCrossSection_TTB
use ModCrossSection_TTBJ
use ModCrossSection_TTBP
use ModCrossSection_TTBP_anomcoupl
use ModCrossSection_TTBZ
use ModCrossSection_TTBH
use ModCrossSection_TH
use ModCrossSection_TTBETmiss
use ModCrossSection_ZprimeTTB
use ModCrossSection_eeTTB
use ModKinematics
use ModParameters
implicit none
include "vegas_common.f"
real(8) :: VG_Result,VG_Error,VG_Chi2
logical :: warmup
include 'mpif.h'
integer i,init;
double precision yrange(1:2*MXDIM)


do i=1,ndim
  yrange(i)=0d0
  yrange(i+ndim)=1d0
enddo
nprn=3


if( GridIO.eq.-1 ) then
  readin=.false.
  writeout=.true.
  outgridfile=GridFile(1:72)
elseif( GridIO.eq.+1 ) then
  readin=.true.
  writeout=.false.
  ingridfile=GridFile(1:72)
elseif( GridIO.eq.+2 ) then
  FirstLOThenVI = .true.
else
  readin=.false.
  writeout=.false.
endif



VegasMxDim=mxdim

if( VegasIt0.eq.0 .OR. VegasNc0.eq.0 ) then
   warmup = .false.
   itmx = VegasIt1
   ncall= VegasNc1
else
   itmx = VegasIt0
   ncall= VegasNc0
   warmup = .true.
endif




IF( MASTERPROCESS.EQ.1 ) THEN
IF( CORRECTION.LE.1 .AND. PROCESS.EQ.1 .AND. TOPDECAYS.NE.101) THEN
  init=0
  call ClearRedHisto()
  call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbgg_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()
    call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbgg_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif

ELSEIF( CORRECTION.LE.1 .AND. PROCESS.EQ.21 ) THEN
  init=0
  call ClearRedHisto()
  call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_DKP_1L_ttbgg_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()
    call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_DKP_1L_ttbgg_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
 endif
ELSEIF( CORRECTION.EQ.3 .AND. PROCESS.LE.5 ) THEN
  init=0
  call ClearRedHisto()
  call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbgg_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()
    call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbgg_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF



IF( MASTERPROCESS.EQ.2 ) THEN
IF( CORRECTION.LE.1 .AND. PROCESS.EQ.2 .AND. TOPDECAYS.NE.101) THEN
  init=0
  call ClearRedHisto()
  call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbqqb_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()
    call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbqqb_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif


ELSEIF( CORRECTION.LE.1 .AND. PROCESS.EQ.23 ) THEN
  init=0
  call ClearRedHisto()
  call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_DKP_1L_ttbqqb_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()
    call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_DKP_1L_ttbqqb_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
 endif
ELSEIF( CORRECTION.EQ.3 .AND. PROCESS.LE.6 ) THEN
  init=0
  call ClearRedHisto()
  call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbqqb_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()
    call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbqqb_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF





IF( MASTERPROCESS.EQ.3 ) THEN
IF( CORRECTION.EQ.2 .AND. PROCESS.EQ.5) THEN
  init=0
  call ClearRedHisto()
  call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_Real_ttbggg_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()
    call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_Real_ttbggg_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF




IF( MASTERPROCESS.EQ.4 ) THEN
IF( CORRECTION.EQ.2 .AND. (PROCESS.EQ.3 .OR. PROCESS.EQ.4 .OR. PROCESS.EQ.6) ) THEN
  init=0
  call ClearRedHisto()
  call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_Real_ttbqqbg_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()
    call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_Real_ttbqqbg_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF



IF( MASTERPROCESS.EQ.8 ) THEN
IF( CORRECTION   .LE.1 ) THEN
  init=0
  call ClearRedHisto()
  call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbggp_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
   init=1
   itmx = VegasIt1
   ncall= VegasNc1
   call InitHisto()
   call ClearRedHisto()
   call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbggp_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif
ELSE
  call Error("this correction is not available")
ENDIF
ENDIF






IF( MASTERPROCESS.EQ.17 ) THEN
IF( CORRECTION.EQ.0 .OR. CORRECTION.EQ.3 ) THEN
  init=0
  call ClearRedHisto()
  if (Process .ge. 71 .and. Process .le. 79) then
     call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbggZ_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  elseif (Process .ge. 81 .and. Process .le. 89) then
     call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_anomcoupl_1L_ttbggp_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif
     
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()
    if (Process .ge. 71 .and. Process .le. 79) then
       call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbggZ_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  elseif (Process .ge. 81 .and. Process .le. 89) then
     call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_anomcoupl_1L_ttbggp_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif
  endif


ELSEIF( CORRECTION   .EQ.1 ) THEN
  if( FirstLOThenVI ) then
      CORRECTION=0
      init=0
      call ClearRedHisto()
      call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbggZ_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
      if( warmup ) then
        init=1
        itmx = VegasIt1
        ncall= VegasNc0
        call InitHisto()
        call ClearRedHisto()
        call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbggZ_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
      endif
        CORRECTION=1
        init=1
        itmx = 1
        ncall= VegasNc1
        call InitHisto()
        call ClearRedHisto()
        call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbggZ_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  else
      init=0
      call ClearRedHisto()
      call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbggZ_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
      if( warmup ) then
        init=1
        itmx = VegasIt1
        ncall= VegasNc1
        call InitHisto()
        call ClearRedHisto()
        call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbggZ_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
      endif
  endif

ELSEIF( CORRECTION.EQ.4 ) THEN
  init=0
  call ClearRedHisto()
  call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_NLODK_ttbZ_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()
    call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_NLODK_ttbZ_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif


ELSEIF( CORRECTION.EQ.5 ) THEN
  init=0
  call ClearRedHisto()
  call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_NLODK_ttbZ_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()
    call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_NLODK_ttbZ_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif


ENDIF
ENDIF




IF( MASTERPROCESS.EQ.18 ) THEN
IF( CORRECTION.EQ.0 .OR. CORRECTION.EQ.3 ) THEN
  init=0
  call ClearRedHisto()
  if (Process .ge. 71 .and. Process .le. 79) then
     call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbqqbZ_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  elseif (Process .ge. 81 .and. Process .le. 89) then
     call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_anomcoupl_1L_ttbqqbp_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif
     
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()
    if (Process .ge. 71 .and. Process .le. 79) then
       call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbqqbZ_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
    elseif (Process .ge. 81 .and. Process .le. 89) then
       call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_anomcoupl_1L_ttbqqbp_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
    endif
  endif

ELSEIF( CORRECTION   .EQ.1 ) THEN
  if( FirstLOThenVI ) then
      CORRECTION=0
      init=0
      call ClearRedHisto()
      call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbqqbZ_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
      if( warmup ) then
        init=1
        itmx = VegasIt1
        ncall= VegasNc0
        call InitHisto()
        call ClearRedHisto()
        call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbqqbZ_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
      endif
        CORRECTION=1
        init=1
        itmx = 1
        ncall= VegasNc1
        call InitHisto()
        call ClearRedHisto()
        call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbqqbZ_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  else
      init=0
      call ClearRedHisto()
      call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbqqbZ_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
      if( warmup ) then
        init=1
        itmx = VegasIt1
        ncall= VegasNc1
        call InitHisto()
        call ClearRedHisto()
        call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbqqbZ_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
      endif
  endif


ELSEIF( CORRECTION.EQ.4 ) THEN
  init=0
  call ClearRedHisto()
  call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_NLODK_ttbZ_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()
    call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_NLODK_ttbZ_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif


ELSEIF( CORRECTION.EQ.5 ) THEN
  init=0
  call ClearRedHisto()
  call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_NLODK_ttbZ_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()
    call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_NLODK_ttbZ_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif


ENDIF
ENDIF




IF( MASTERPROCESS.EQ.19 ) THEN
IF( CORRECTION.EQ.2 ) THEN
  init=0
  call ClearRedHisto()
  call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_Real_ttbgggZ_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()
    call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_Real_ttbgggZ_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF



IF( MASTERPROCESS.EQ.20 ) THEN
IF( CORRECTION.EQ.2 ) THEN
  init=0
  call ClearRedHisto()
  call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_Real_ttbqqbgZ_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()
    call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_Real_ttbqqbgZ_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF





IF( MASTERPROCESS.EQ.21 ) THEN
IF( CORRECTION   .EQ.0 ) THEN
  init=0
  call ClearRedHisto()
  call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ee_ttb,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()
   call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ee_ttb,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif

ELSEIF( CORRECTION .EQ.1 ) THEN
  if( FirstLOThenVI ) then
      CORRECTION=0
      init=0
      call ClearRedHisto()
      call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ee_ttb,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
      if( warmup ) then
        init=1
        itmx = VegasIt1
        ncall= VegasNc1
        call InitHisto()
        call ClearRedHisto()
        call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ee_ttb,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
      endif
      init=1
      itmx = 1
      ncall= VegasNc1
      call InitHisto()
      call ClearRedHisto()
      CORRECTION=1
      call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ee_ttb,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  else
      init=0
      call ClearRedHisto()
      call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ee_ttb,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
      if( warmup ) then
        init=1
        itmx = VegasIt1
        ncall= VegasNc1
        call InitHisto()
        call ClearRedHisto()
        call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ee_ttb,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
      endif
  endif


ELSEIF( CORRECTION.EQ.3 ) THEN
  init=0
  call ClearRedHisto()
  call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ee_ttb,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()
    call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ee_ttb,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.4 ) THEN
  init=0
  call ClearRedHisto()
  call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_NLODK_ee_ttb,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()   
    call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_NLODK_ee_ttb,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif
ELSEIF( CORRECTION.EQ.5 ) THEN
  init=0
  call ClearRedHisto()
  call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_NLODK_ee_ttb,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()   
    call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_NLODK_ee_ttb,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF

ENDIF




IF( MASTERPROCESS.EQ.22 ) THEN
IF( CORRECTION.EQ.2 ) THEN
  call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_Real_ee_ttbg,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()   
    call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_Real_ee_ttbg,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF

ENDIF







IF( MASTERPROCESS.EQ.23 ) THEN
IF( CORRECTION.EQ.0 .OR. CORRECTION.EQ.3 ) THEN
  init=0
  call ClearRedHisto()
  call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbggH_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()
    call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbggH_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif


ELSEIF( CORRECTION   .EQ.1 ) THEN
  if( FirstLOThenVI ) then
      CORRECTION=0
      init=0
      call ClearRedHisto()
      call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbggH_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
      if( warmup ) then
        init=1
        itmx = VegasIt1
        ncall= VegasNc0
        call InitHisto()
        call ClearRedHisto()
        call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbggH_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
      endif
        CORRECTION=1
        init=1
        itmx = 1
        ncall= VegasNc1
        call InitHisto()
        call ClearRedHisto()
        call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbggH_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  else
      init=0
      call ClearRedHisto()
      call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbggH_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
      if( warmup ) then
        init=1
        itmx = VegasIt1
        ncall= VegasNc1
        call InitHisto()
        call ClearRedHisto()
        call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbggH_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
      endif
  endif

ELSEIF( CORRECTION.EQ.4 ) THEN
  init=0
  call ClearRedHisto()
  call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_NLODK_ttbH_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()
    call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_NLODK_ttbH_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif


ELSEIF( CORRECTION.EQ.5 ) THEN
  init=0
  call ClearRedHisto()
  call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_NLODK_ttbH_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()
    call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_NLODK_ttbH_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif


ENDIF
ENDIF




IF( MASTERPROCESS.EQ.24 ) THEN
IF( CORRECTION.EQ.0 .OR. CORRECTION.EQ.3 ) THEN
  init=0
  call ClearRedHisto()
  call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbqqbH_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()
    call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbqqbH_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif

ELSEIF( CORRECTION   .EQ.1 ) THEN
  if( FirstLOThenVI ) then
      CORRECTION=0
      init=0
      call ClearRedHisto()
      call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbqqbH_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
      if( warmup ) then
        init=1
        itmx = VegasIt1
        ncall= VegasNc0
        call InitHisto()
        call ClearRedHisto()
        call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbqqbH_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
      endif
        CORRECTION=1
        init=1
        itmx = 1
        ncall= VegasNc1
        call InitHisto()
        call ClearRedHisto()
        call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbqqbH_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  else
      init=0
      call ClearRedHisto()
      call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbqqbH_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
      if( warmup ) then
        init=1
        itmx = VegasIt1
        ncall= VegasNc1
        call InitHisto()
        call ClearRedHisto()
        call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_ttbqqbH_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
      endif
  endif


ELSEIF( CORRECTION.EQ.4 ) THEN
  init=0
  call ClearRedHisto()
  call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_NLODK_ttbH_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()
    call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_NLODK_ttbH_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif


ELSEIF( CORRECTION.EQ.5 ) THEN
  init=0
  call ClearRedHisto()
  call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_NLODK_ttbH_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()
    call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_NLODK_ttbH_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif


ENDIF
ENDIF




IF( MASTERPROCESS.EQ.25 ) THEN
IF( CORRECTION.EQ.2 ) THEN
  init=0
  call ClearRedHisto()
  call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_Real_ttbgggH_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()
    call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_Real_ttbgggH_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF



IF( MASTERPROCESS.EQ.26 ) THEN
IF( CORRECTION.EQ.2 ) THEN
  init=0
  call ClearRedHisto()
  call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_Real_ttbqqbgH_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()
    call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_Real_ttbqqbgH_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF









IF( MASTERPROCESS.EQ.62 ) THEN
IF( (CORRECTION.LE.1) .AND. PROCESS.EQ.62 ) THEN
   init=0
   call ClearRedHisto()
!    call qlinit()
!    call ltini ! looptools
  call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_Zprime_ttbqqb_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()
    call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_1L_Zprime_ttbqqb_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif

ENDIF
ENDIF



IF( MASTERPROCESS.EQ.73 ) THEN
IF( CORRECTION.EQ.0 .OR. CORRECTION.EQ.3 ) THEN
  init=0
  call ClearRedHisto()
  call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_LO_tdubH_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()
    call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_LO_tdubH_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF

IF( MASTERPROCESS.EQ.74 ) THEN
IF( CORRECTION.EQ.0 .OR. CORRECTION.EQ.3 ) THEN
  init=0
  call ClearRedHisto()
  call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_LO_tbardubbarH_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  if( warmup ) then
    init=1
    itmx = VegasIt1
    ncall= VegasNc1
    call InitHisto()
    call ClearRedHisto()
    call vegas_mpi(yrange(1:2*ndim),ndim,EvalCS_LO_tbardubbarH_MPI,init,ncall,itmx,nprn,NUMFUNCTIONS,PDIM,WORKERS,VG_Result,VG_Error,VG_Chi2)
  endif
ENDIF
ENDIF




return
END SUBROUTINE
!DEC$ ENDIF











SUBROUTINE InitVegas()
use ModKinematics
use ModParameters
implicit none
include "vegas_common.f"

  VegasIt0_default = 3
  VegasIt1_default = 5

  idum = -VegasSeed
  xl(1:mxdim) = 0d0
  xu(1:mxdim) = 1d0
  acc = -1d0
  nprn = 1
  readin=.false.
  writeout=.false.
!DEC$ IF(_UseMPIVegas .EQ.1)
  it = 1   ! this has to be fixed for PVegas because the division by curit is done already in the c code
!DEC$ ENDIF

  if( VegasIt0.eq.-1 ) VegasIt0 = VegasIt0_default
  if( VegasNc0.eq.-1 ) VegasNc0 = VegasNc0_default
  if( VegasIt1.eq.-1 ) VegasIt1 = VegasIt1_default
  if( VegasNc1.eq.-1 ) VegasNc1 = VegasNc1_default

return
END SUBROUTINE





SUBROUTINE InitPDFs()
use ModParameters
use ModMisc
implicit none


#if _UseLHAPDF==1

     if( Collider.eq.2 ) call Error("proton-antiproton collisions not implemented for LHAPDFs")
     IF( NLOPARAM.EQ.0 .OR. NLOPARAM.EQ.1 ) THEN
         PDFSetString(:) = "NNPDF30_lo_as_0130"
!          PDFSetString(:) = "MSTW2008lo68cl"
     ELSEIF( NLOPARAM.EQ.2) THEN
         PDFSetString(:) = "NNPDF30_nlo_as_0118"
!          PDFSetString(:) = "MSTW2008nlo68cl"
     ENDIF
     
     call InitPDFset(trim(PDFSetString))
     call InitPDF(LHAPDFMember)  
     
#else


IF( PDFSET.EQ.1 ) THEN! MRST/MSTW
! no initialization necessary
  IF( NLOPARAM.EQ.2) THEN
      PDFSetString(:) = " MSTW2008 NLO (mstw2008nlo.00.dat)"
  ELSEIF( NLOPARAM.EQ.0 .OR. NLOPARAM.EQ.1 ) THEN
      PDFSetString(:) = " MSTW2008 LO (mstw2008lo.00.dat)"
  ENDIF



ELSEIF( PDFSET  .EQ.2 ) THEN! CTEQ
  IF( NLOPARAM.EQ.2) THEN
!       call SetCtq6(1) !  CTEQ6M   Standard MSbar scheme   0.118     326   226    cteq6m.tbl
!       call SetCtq6(200) !  updated CTEQ6.1M Standard MSbar scheme   0.118     326   226    cteq6m.tbl

!     call SetCtq6(400) !  CTEQ6.6M;                        0.118     326   226    ctq66.00.pds
!     PDFSetString(:) = " CTEQ6.6M NLO (ctq66.00.pds)"

      call SetCT10(100)!   Central CT10           0.118      ct10.00.pds
      PDFSetString = "CTEQ10 NLO (ct10.00.pds)"!   check that cteq10 is used in mod_kinematics

  ELSEIF( NLOPARAM.EQ.0 .OR. NLOPARAM.EQ.1 ) THEN
     call SetCtq6(4)  ! CTEQ6L1  Leading Order           0.130**   215** 165    cteq6l1.tbl
     PDFSetString(:) = " CTEQ6L1 LO"
  ENDIF
ENDIF


#endif




return
END SUBROUTINE




SUBROUTINE OpenFiles()
use ModParameters
implicit none
character :: filename*(100)

!    filename = trim(HistoFile)//'.dat'
!    open(unit=14,file=trim(filename),form='formatted',access= 'sequential',status='replace')            ! Histogram file

!    filename = trim(HistoFile)//'.status'
!    open(unit=15,file=trim(filename),form='formatted',access= 'sequential',status='replace')         ! Vegas status file

!    filename = trim(HistoFile)//'.tmp_histo'
!    open(unit=16,file=trim(filename),form='formatted',access= 'sequential',status='replace')         ! Histo status file

return
END SUBROUTINE



SUBROUTINE CloseFiles()
implicit none

!    close(14)
!    close(15)
!    close(16)

return
END SUBROUTINE




SUBROUTINE WriteHisto(TheUnit,curit,VG_CurrResult,VG_CurrError,VG_Result,VG_Error,Chi2,RunTime)
use ModKinematics
use ModParameters
implicit none
include "vegas_common.f"
integer :: NBin,Hits,NHisto,SumHits,TheUnit,curit,NBin2,NBin3,NHisto2
real(8) :: BinSize,LowVal,BinVal,Value,Error,Integral
real(8) :: BinSize2,BinSize3,LowVal2,LowVal3,BinVal2,BinVal3
real(8),parameter :: ToGeV=1d2, ToPb=1d-3
real(8) :: VG_Result,VG_Error,RunTime,VG_CurrResult,VG_CurrError,Chi2
character :: filename*(100),arg*(500)
logical, save :: FirstTime=.true.


  if(TheUnit.ne.6) then 
    filename = trim(HistoFile)//'.dat'
    open(unit=TheUnit,  file=trim(filename),form='formatted',access= 'sequential',status='replace')   ! Histogram file
    if( Num2DHistograms.gt.0 ) then
        filename = trim(HistoFile)//'_2D'//'.dat'
        open(unit=TheUnit+200,  file=trim(filename),form='formatted',access= 'sequential',status='replace')   ! 2-d Histogram file
    endif
!   writing status file
    filename = trim(HistoFile)//'.status'
    if( FirstTime ) then
        open(unit=TheUnit+1,file=trim(filename),form='formatted',access= 'sequential',status='replace')   ! status file
        call Get_Command(arg)
        write(TheUnit+1,'(A1,1X,A)') "#","-------------------------------------------------------------------------------------------------"
        write(TheUnit+1,'(A1,1X,A)') "#",trim(arg)
        write(TheUnit+1,'(A1,1X,A)') "#","-------------------------------------------------------------------------------------------------"
        write(TheUnit+1,'(A1,1X,A)') "#","  It.    Result              Error               Accum. result       Accum. error         Chi^2  "
        write(TheUnit+1,'(A1,1X,A)') "#","-------------------------------------------------------------------------------------------------"
        FirstTime=.false. 
      else
        open(unit=TheUnit+1,file=trim(filename),form='formatted',access= 'sequential',status='old',position='append')   ! status file
        if( curit.eq.1 ) write(TheUnit+1,'(A1,1X,A)') "#","-------------------------------------------------------------------------------------------------"
    endif
    if( curit.gt.0 ) write(TheUnit+1,'(A1,1X,I3,4E20.8,F12.2)') "#",curit,VG_CurrResult,VG_CurrError,VG_Result,VG_Error,Chi2
  endif

  call WriteParameters(TheUnit)
  write(TheUnit,"(A,2X,1F9.2,A)") "# run time =",RunTime/60d0,"min"
  write(TheUnit,"(A,2X,1F20.10)") "# EvalCounter  =",dble(EvalCounter)
  write(TheUnit,"(A,2X,1F20.10)") "# PSCutCounter =",dble(PSCutCounter)
  write(TheUnit,"(A,2X,1F20.10)") "# SkipCounter  =",dble(SkipCounter)
  if( EvalCounter.gt.0 .and. dble(SkipCounter)/dble(EvalCounter) .gt. 0.02d0 ) write(TheUnit,"(A,2X)") "# **** WARNING  ****: SkipCounter is larger than 2%"
  write(TheUnit,"(A,2X,1PE20.10,2X,1PE20.5)") "#TotCS[fb]=",VG_Result,VG_Error
  do NHisto=1,NumHistograms
!     print *, NHisto
      write(TheUnit,"(A,I2,A,A)") "# Histogram",NHisto,": ",Histo(NHisto)%Info
      Integral = 0d0
      SumHits = 0
      BinSize = Histo(NHisto)%BinSize * Histo(NHisto)%SetScale
      LowVal  = Histo(NHisto)%LowVal  * Histo(NHisto)%SetScale
      do NBin=1, Histo(NHisto)%NBins
!         print *, NBin
          BinVal = (LowVal+(NBin-1)*BinSize)
          Hits   = Histo(NHisto)%Hits(NBin)
          SumHits = SumHits + Hits
          
          if( unweighted ) then
              Value  = Histo(NHisto)%Value(NBin)/BinSize
              Integral = Integral + Histo(NHisto)%Value(NBin)
              Error  = 1d0/dsqrt(dble(Hits))
          else
              Value  = Histo(NHisto)%Value(NBin)/BinSize/curit
!              print *, Histo(NHisto)%Value(NBin), BinSize,curit
              Integral = Integral + Histo(NHisto)%Value(NBin)/curit
              Error  = 1d0/(BinSize)/curit * dsqrt(dabs( Histo(NHisto)%Value2(NBin) - 1d0/curit/ncall*Histo(NHisto)%Value(NBin)**2) )
          endif
          if(Hits.ge.999999999) Hits=999999999

          write(TheUnit,"(I2,A,2X,1PE10.3,A,2X,1PE23.16,A,2X,1PE23.16,A,2X,I9,A)") NHisto,"|",BinVal,"|",Value,"|",Error,"|",Hits,"|"

          if (Histo(NHisto)%Info(1:3).eq."2D_") then
! now we have a two-dim histogram -- change output accordingly
             NHisto2=NHisto-NumHistograms+Num2DHistograms
             NBin2=mod(NBin,Histo2D(NHisto2)%NBins2)
             if (NBin2==0) NBin2=Histo2D(NHisto2)%NBins2
             NBin3=ceiling(NBin*1d0/Histo2D(NHisto2)%NBins2)
             BinSize2 = Histo2D(NHisto2)%BinSize2 * Histo2D(NHisto2)%SetScale2
             LowVal2  = Histo2D(NHisto2)%LowVal2  * Histo2D(NHisto2)%SetScale2
             BinSize3 = Histo2D(NHisto2)%BinSize3 * Histo2D(NHisto2)%SetScale3
             LowVal3  = Histo2D(NHisto2)%LowVal3  * Histo2D(NHisto2)%SetScale3

             BinVal2=LowVal2+(NBin2-1)*BinSize2
             BinVal3=LowVal3+(NBin3-1)*BinSize3
             if (unweighted) then
                ! not implemented yet...
             else
                Value=Histo(NHisto)%Value(NBin)/BinSize2/BinSize3/curit
!NB error not implemented yet...
                Error=0d0
             endif
             if( Num2DHistograms.gt.0 ) write(TheUnit+200,"(I2,A,2X,1PE10.3,A,2X,1PE10.3,A,2X,1PE23.16,A,2X,1PE23.16,A,2X,I9,A)") NHisto,"|",BinVal2,"|",BinVal3,"|",Value,"|",Error,"|",Hits,"|"
          endif

       enddo
      Integral = Integral + (Histo(NHisto)%Value(0)+Histo(NHisto)%Value(Histo(NHisto)%NBins+1))/curit
      write(TheUnit,"(A,2X,1PE23.16)") "# integrated result:",Integral
      write(TheUnit,"(A,2X,1I23)") "# total number of hits:",SumHits
  enddo

!!! now for the two-dim histograms
!!!  do NHisto=1,Num2DHistograms
!!!     write(TheUnit,"(A,I2,A,A)") "# Histogram",NumHistograms+NHisto,": ",Histo2D(NHisto)%Info
!!!     Integral =0d0
!!!     SumHits = 0
!!!     BinSize2 = Histo2D(NHisto)%BinSize2 * Histo2D(NHisto)%SetScale2
!!!     LowVal2  = Histo2D(NHisto)%LowVal2  * Histo2D(NHisto)%SetScale2
!!!     BinSize3 = Histo2D(NHisto)%BinSize3 * Histo2D(NHisto)%SetScale3
!!!     LowVal3  = Histo2D(NHisto)%LowVal3  * Histo2D(NHisto)%SetScale3
!!!     do NBin2=1, Histo(NHisto)%NBins2
!!!        BinVal2 = (LowVal2+(NBin2-1)*BinSize2)
!!!
!!!        do NBin3=1, Histo(NHisto)%NBins3
!!!           BinVal3 = (LowVal2+(NBin2-1)*BinSize2)
!!!           Hits=Histo(NHisto)%Hits(NBin)
!!!
        
  




  if(TheUnit.ne.6) then
    close(TheUnit)
    close(TheUnit+1)
    if( Num2DHistograms.gt.0 ) close(TheUnit+200)
  endif

return
END SUBROUTINE



SUBROUTINE WriteInstantHisto()
use ModKinematics
use ModParameters
implicit none
include "vegas_common.f"
integer :: NBin,Hits,NHisto
real(8) :: BinSize,LowVal,BinVal,Value,Error,Integral
real(8),parameter :: ToGeV=1d2, ToPb=1d-3
real(8) :: VG_Result,VG_Error,RunTime
character :: filename*(100)

  filename = trim(HistoFile)//'.tmp_histo'
  open(unit=16,file=trim(filename),form='formatted',access= 'sequential',status='replace')         ! Histo status file

  write(16,"(A)") "#"
  write(16,"(A,I3)") "# temporary histogram ",it-1
  write(16,"(A,2X,1F20.10)") "# EvalCounter  =",dble(EvalCounter)
  write(16,"(A,2X,1F20.10)") "# PSCutCounter =",dble(PSCutCounter)
  write(16,"(A,2X,1F20.10)") "# SkipCounter  =",dble(SkipCounter)
  do NHisto=1,NumHistograms
      write(16,"(A,I2,A,A)") "# Histogram",NHisto,": ",Histo(NHisto)%Info
      Integral = 0d0
      BinSize = Histo(NHisto)%BinSize * Histo(NHisto)%SetScale
      LowVal  = Histo(NHisto)%LowVal  * Histo(NHisto)%SetScale
      do NBin=1, Histo(NHisto)%NBins
          BinVal = (LowVal+(NBin-1)*BinSize)
          Hits   = Histo(NHisto)%Hits(NBin)
          Value  = Histo(NHisto)%Value(NBin)/BinSize/(it-1)
          Integral = Integral + Histo(NHisto)%Value(NBin)/(it-1)
          Error  = 1d0/(BinSize)/(it-1) * dsqrt( Histo(NHisto)%Value2(NBin) - 1d0/(it-1)/ncall*Histo(NHisto)%Value(NBin)**2 )
          write(16,"(I2,A,2X,1PE10.3,A,2X,1PE23.16,A,2X,1PE23.16,A,2X,I9,A)") NHisto,"|",BinVal,"|",Value,"|",Error,"|",Hits,"|"
      enddo
      Integral = Integral + (Histo(NHisto)%Value(0)+Histo(NHisto)%Value(Histo(NHisto)%NBins+1))/(it-1)
      write(16,"(A,2X,1PE23.16)") "# integrated result:",Integral
      write(16,"(A)") "#"
  enddo

  close(16)

return
END SUBROUTINE




SUBROUTINE PlotVegas()
use ModParameters
use ifport
implicit none
include "vegas_common.f"
character :: filename*(100),istr*(2)
integer :: res

    filename = trim(HistoFile)
    write(istr,"(I2)") it

    res = system("./misc/PlotVegasRun.sh "//trim(filename)//" "//trim(istr))
    if( res.eq.-1 ) then
        res = system("./PlotVegasRun.sh "//trim(filename)//" "//trim(istr))
        if( res.eq.-1 ) then
            print *, "Error plotting vegas convergence"
        else
        print *, "Vegas convergence has been plotted in ",trim(filename)//".eps"
        endif
    else
        print *, "Vegas convergence has been plotted in ",trim(filename)//".eps"
    endif


return
END SUBROUTINE


