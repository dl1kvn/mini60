import 'package:flutter/material.dart';

final List<Map<String, String>> antennaTypes = [
  {'name': '01-Tee Antenna', 'imagePath': 'assets/images/01-teeantenna.jpg'},
  {
    'name': '02-The Half-Lamda Tee Antenna',
    'imagePath': 'assets/images/02-thehalf-lamdateeantenna.jpg',
  },
  {
    'name': '03-Twin-Led Marconi Antenna',
    'imagePath': 'assets/images/03-twin-ledmarconiantenna.jpg',
  },
  {
    'name': '04-Swallow-Tail Antenna',
    'imagePath': 'assets/images/04-swallow-tailantenna.jpg',
  },
  {
    'name': '05-Random-Length Radiator Wire',
    'imagePath': 'assets/images/05-random-lengthradiatorwire.jpg',
  },
  {
    'name': '06-Windom Antenna',
    'imagePath': 'assets/images/06-windomantenna.jpg',
  },
  {
    'name': '08-Quarter Wavelength Vertical Antenna',
    'imagePath': 'assets/images/08-quarterwavelengthverticalantenna.jpg',
  },
  {
    'name': '09-Folded Marconi Tee Antenna',
    'imagePath': 'assets/images/09-foldedmarconiteeantenna.jpg',
  },
  {
    'name': '10-Zeppelin Antenna',
    'imagePath': 'assets/images/10-zeppelinantenna.jpg',
  },
  {'name': '11-EWE Antenna', 'imagePath': 'assets/images/11-eweantenna.jpg'},
  {
    'name': '12-Dipole Antenna - Balun',
    'imagePath': 'assets/images/12-dipoleantenna-balun.jpg',
  },
  {
    'name': '13-Multi-band Dipole Antenna',
    'imagePath': 'assets/images/13-multi-banddipoleantenna.jpg',
  },
  {
    'name': '14-Inverted-Vee Antenna',
    'imagePath': 'assets/images/14-inverted-veeantenna.jpg',
  },
  {
    'name': '15-Sloping Dipole Antenna',
    'imagePath': 'assets/images/15-slopingdipoleantenna.jpg',
  },
  {
    'name': '16-Vertical Dipole Antenna',
    'imagePath': 'assets/images/16-verticaldipoleantenna.jpg',
  },
  {
    'name': '17-Delta-Fed Dipole Antenna',
    'imagePath': 'assets/images/17-delta-feddipoleantenna.jpg',
  },
  {
    'name': '18-Bow-Tie Dipole Antenna - 1',
    'imagePath': 'assets/images/18-bow-tiedipoleantenna-1.jpg',
  },
  {
    'name': '19-Bow-Tie Dipole Antenna - for RX',
    'imagePath': 'assets/images/19-bow-tiedipoleantenna-forrx.jpg',
  },
  {
    'name': '20-Multiband Tuned Doublet Antenna',
    'imagePath': 'assets/images/20-multibandtuneddoubletantenna.jpg',
  },
  {'name': '21-G5RV Antenna', 'imagePath': 'assets/images/21-g5rvantenna.jpg'},
  {
    'name': '22-Wideband Dipole Antenna',
    'imagePath': 'assets/images/22-widebanddipoleantenna.jpg',
  },
  {
    'name': '23-Wideband Dipole for Receiving',
    'imagePath': 'assets/images/23-widebanddipoleforreceiving.jpg',
  },
  {
    'name': '24-Tilted Folded Dipole Antenna',
    'imagePath': 'assets/images/24-tiltedfoldeddipoleantenna.jpg',
  },
  {
    'name': '25-The Right-Angle Marconi Antenna',
    'imagePath': 'assets/images/25-theright-anglemarconiantenna.jpg',
  },
  {
    'name': '26-Linearly Loaded Tee Antenna',
    'imagePath': 'assets/images/26-linearlyloadedteeantenna.jpg',
  },
  {
    'name': '27-Reduced Size Dipole Antenna',
    'imagePath': 'assets/images/27-reducedsizedipoleantenna.jpg',
  },
  {
    'name': '28-Doublet Dipole Antenna',
    'imagePath': 'assets/images/28-doubletdipoleantenna.jpg',
  },
  {
    'name': '29-Delta Loop Antenna',
    'imagePath': 'assets/images/29-deltaloopantenna.jpg',
  },
  {
    'name': '30-Half Delta Loop Antenna',
    'imagePath': 'assets/images/30-halfdeltaloopantenna.jpg',
  },
  {
    'name': '31-Colinear Franklin Antenna',
    'imagePath': 'assets/images/31-colinearfranklinantenna.jpg',
  },
  {
    'name': '32-Four Element Broadside Array Antenna',
    'imagePath': 'assets/images/32-fourelementbroadsidearrayantenna.jpg',
  },
  {
    'name': '33-The Lazy-H Array Antenna',
    'imagePath': 'assets/images/33-thelazy-harrayantenna.jpg',
  },
  {
    'name': '34-Sterba Curtain Array Antenna',
    'imagePath': 'assets/images/34-sterbacurtainarrayantenna.jpg',
  },
  {
    'name': '35-T-L DX Antenna',
    'imagePath': 'assets/images/35-t-ldxantenna.jpg',
  },
  {'name': '36-1', 'imagePath': 'assets/images/36-1.jpg'},
  {
    'name': '37-Multiband Portable Antenna',
    'imagePath': 'assets/images/37-multibandportableantenna.jpg',
  },
  {
    'name': '38-Off-center-fed full-wave doublet',
    'imagePath': 'assets/images/38-off-center-fedfull-wavedoublet.jpg',
  },
  {
    'name': '39-Terminated sloper antenna',
    'imagePath': 'assets/images/39-terminatedsloperantenna.jpg',
  },
  {
    'name': '40-Double extended Zepp antenna',
    'imagePath': 'assets/images/40-doubleextendedzeppantenna.jpg',
  },
  {
    'name': '41-TCFTFD dipole antenna',
    'imagePath': 'assets/images/41-tcftfddipoleantenna.jpg',
  },
  {
    'name': '42-Vee-sloper antenna',
    'imagePath': 'assets/images/42-vee-sloperantenna.jpg',
  },
  {
    'name': '43-Rhombic inverted-vee antenna',
    'imagePath': 'assets/images/43-rhombicinverted-veeantenna.jpg',
  },
  {
    'name': '44-Counterpoise longwire',
    'imagePath': 'assets/images/44-counterpoiselongwire.jpg',
  },
  {
    'name': '45-Bisquare loop antenna',
    'imagePath': 'assets/images/45-bisquareloopantenna.jpg',
  },
  {
    'name': '46-Piggyback antenna for 10m',
    'imagePath': 'assets/images/46-Piggyback_antenna_for_10m.jpg',
  },
  {
    'name': '47-Vertical Sleeve Antenna for 10m',
    'imagePath': 'assets/images/47-Vertical_Sleeve_Antenna_for_10m.jpg',
  },
  {
    'name': '48-Double Windom Antenna',
    'imagePath': 'assets/images/48-Double_Windom_Antenna.jpg',
  },
  {
    'name': '49-Double Windom for 9-bands',
    'imagePath': 'assets/images/49-Double_Windom_for_9-bands.jpg',
  },
  {
    'name': '50-Collinear Trap Antenna',
    'imagePath': 'assets/images/50-Collinear_Trap_Antenna.jpg',
  },
  {
    'name': '51-Short Dipole Antenna for 40m-80m-160m',
    'imagePath': 'assets/images/51-Short_Dipole_Antenna_for_40m-80m-160m.jpg',
  },
  {
    'name': '52-Center-Fed Zepp Antenna for 80m-40m',
    'imagePath': 'assets/images/52-Center-Fed_Zepp_Antenna_for_80m-40m.jpg',
  },
  {
    'name': '53-All-bands Antenna',
    'imagePath': 'assets/images/53-All-bands_Antenna.jpg',
  },
  {
    'name': '54-All-bands Dipole Antenna',
    'imagePath': 'assets/images/54-All-bands_Dipole_Antenna.jpg',
  },
  {
    'name': '55-Multiband Z Antenna',
    'imagePath': 'assets/images/55-Multiband_Z_Antenna.jpg',
  },
  {
    'name': '56-Multiband Dipole Antenna',
    'imagePath': 'assets/images/56-Multiband_Dipole_Antenna.jpg',
  },
  {
    'name': '57-Five-Bands no tuner Antenna',
    'imagePath': 'assets/images/57-Five-Bands_no_tuner_Antenna.jpg',
  },
  {
    'name': '58-Dualband Full-wave Loop Antenna 80m-40m',
    'imagePath': 'assets/images/58-Dualband_Full-wave_Loop_Antenna_80m-40m.jpg',
  },
  {
    'name': '59-Loop Antenna for 10m',
    'imagePath': 'assets/images/59-Loop_Antenna_for_10m.jpg',
  },
  {
    'name': '60-10m Lazy Quad Antenna',
    'imagePath': 'assets/images/60-10m_Lazy_Quad_Antenna.jpg',
  },
  {
    'name': '61-Tri-band Delta Loop Antenna 80m 40m 30m',
    'imagePath': 'assets/images/61-Tri-band_Delta_Loop_Antenna_80m_40m_30m.jpg',
  },
  {
    'name': '62-Dual-band Loop Antenna 30m-40m',
    'imagePath': 'assets/images/62-Dual-band_Loop_Antenna_30m-40m.jpg',
  },
  {
    'name': '63-Wire-Beam Antenna for 80m',
    'imagePath': 'assets/images/63-Wire-Beam_Antenna_for_80m.jpg',
  },
  {
    'name': '64-Dual-Band Sloper Antenna',
    'imagePath': 'assets/images/64-Dual-Band_Sloper_Antenna.jpg',
  },
  {
    'name': '65-Inverted-V Beam Antenna for 30m',
    'imagePath': 'assets/images/65-Inverted-V_Beam_Antenna_for_30m.jpg',
  },
  {
    'name': '66-ZL-Special Beam Antenna for 15m',
    'imagePath': 'assets/images/66-ZL-Special_Beam_Antenna_for_15m.jpg',
  },
  {
    'name': '67-Half-Sloper Antenna for 160m',
    'imagePath': 'assets/images/67-Half-Sloper_Antenna_for_160m.jpg',
  },
  {
    'name': '68-Two-Bands Half Sloper 80m-40m',
    'imagePath': 'assets/images/68-Two-Bands_Half_Sloper_80m-40m.jpg',
  },
  {
    'name': '69-Linear Loade Sloper for 160m',
    'imagePath': 'assets/images/69-Linear_Loade_Sloper_for_160m.jpg',
  },
  {
    'name': '70-Super-Sloper Antenna',
    'imagePath': 'assets/images/70-Super-Sloper_Antenna.jpg',
  },
  {
    'name': '71-Tower-as-a-Vertical Antenna for 80m',
    'imagePath': 'assets/images/71-Tower-as-a-Vertical_Antenna_for_80m.jpg',
  },
  {
    'name': '72-Clothesline Antenna',
    'imagePath': 'assets/images/72-Clothesline_Antenna.jpg',
  },
  {
    'name': '73-Curtain Zepp 160m 80m 40m',
    'imagePath': 'assets/images/73-Curtain_Zepp_160m_80m_40m.jpg',
  },
  {
    'name': '74-Collinear Array 40m 30m 20m',
    'imagePath': 'assets/images/74-Collinear_Array_40m_30m_20m.jpg',
  },
  {
    'name': '75-160 Meter Inverted Delta Loop',
    'imagePath': 'assets/images/75-160_Meter_Inverted_Delta_Loop.jpg',
  },
  {
    'name': '76-Half Rhombic Unidirectional Vertical 20m-to-6m',
    'imagePath':
        'assets/images/76-Half_Rhombic_Unidirectional_Vertical_20m-to-6m.jpg',
  },
  {
    'name': '77-Capacitance Loaded 160-meter Vertical',
    'imagePath': 'assets/images/77-Capacitance_Loaded_160-meter_Vertical.jpg',
  },
  {
    'name': '78-Fan Dipole 80m-to-6m',
    'imagePath': 'assets/images/78-Fan_Dipole_80m-to-6m.jpg',
  },
  {
    'name': '79-Wire Ground Plane Antenna',
    'imagePath': 'assets/images/79-Wire_Ground_Plane_Antenna.jpg',
  },
  {
    'name': '80-Inverted Delta Loop for 160m',
    'imagePath': 'assets/images/80-Inverted_Delta_Loop_for_160m.jpg',
  },
  {
    'name': '81-Inverted-L for 160m',
    'imagePath': 'assets/images/81-Inverted-L_for_160m.jpg',
  },
  {
    'name': '82-300ohm-Ribbon Dual Band Dipole',
    'imagePath': 'assets/images/82-300ohm-Ribbon_Dual_Band_Dipole.jpg',
  },
  {
    'name': '83-Tri-Band Beam 20-15-10m',
    'imagePath': 'assets/images/83-Tri-Band_Beam_20-15-10m.jpg',
  },
  {
    'name': '84-Mini-Horse Yagi Antenna',
    'imagePath': 'assets/images/84-Mini-Horse_Yagi_Antenna.jpg',
  },
  {
    'name': '85-Backpack J-Pole Ant 10m-6m-2m',
    'imagePath': 'assets/images/85-Backpack_J-Pole_Ant_10m-6m-2m.jpg',
  },
  {
    'name': '86-Fan Dipole 804020m',
    'imagePath': 'assets/images/86-Fan_Dipole_804020m.jpg',
  },
  {
    'name': '87-Capacity Tuned Folded Loop Ant 20m',
    'imagePath': 'assets/images/87-Capacity_Tuned_Folded_Loop_Ant_20m.jpg',
  },
  {
    'name': '88-Indoor Loop Ant 80m-to-30m',
    'imagePath': 'assets/images/88-Indoor_Loop_Ant_80m-to-30m.jpg',
  },
  {
    'name': '89-Indoor Loop Ant 80m',
    'imagePath': 'assets/images/89-Indoor_Loop_Ant_80m.jpg',
  },
  {
    'name': '90-Double-Delta Ant 80m-40m',
    'imagePath': 'assets/images/90-Double-Delta_Ant_80m-40m.jpg',
  },
  {
    'name': '91-Inductance-Loaded Shortened Dipole 160m',
    'imagePath': 'assets/images/91-Inductance-Loaded_Shortened_Dipole_160m.jpg',
  },
  {'name': '92-V-Beam 15m', 'imagePath': 'assets/images/92-V-Beam_15m.jpg'},
  {
    'name': '93-Picknic Vertical Wire',
    'imagePath': 'assets/images/93-Picknic_Vertical_Wire.jpg',
  },
  {
    'name': '94-Laid-Back Quad Ant 80m',
    'imagePath': 'assets/images/94-Laid-Back_Quad_Ant_80m.jpg',
  },
  {
    'name': '95-Phased Loop Antenna',
    'imagePath': 'assets/images/95-Phased_Loop_Antenna.jpg',
  },
  {
    'name': '96-Loop Ant TX 160m',
    'imagePath': 'assets/images/96-Loop_Ant_TX_160m.jpg',
  },
  {
    'name': '97-Morgain-Dipole Antenna 160m-80m',
    'imagePath': 'assets/images/97-Morgain-Dipole_Antenna_160m-80m.jpg',
  },
  {
    'name': '98-ZL-Special 20-15-10m',
    'imagePath': 'assets/images/98-ZL-Special_20-15-10m.jpg',
  },
  {
    'name': '99-Biconical Antenna',
    'imagePath': 'assets/images/99-Biconical_Antenna.jpg',
  },
  {
    'name': '100-Directive Delta-Birdcage Ant 20m-10m',
    'imagePath': 'assets/images/100-Directive_Delta-Birdcage_Ant_20m-10m.jpg',
  },
  {
    'name': '101-Dual Polarization Ant 80m-40m',
    'imagePath': 'assets/images/101-Dual_Polarization_Ant_80m-40m.jpg',
  },
  {
    'name': '102-Directive 300-ohm-Ribbon Folded Dipole 15m',
    'imagePath':
        'assets/images/102-Directive_300-ohm-Ribbon_Folded_Dipole_15m.jpg',
  },
  {
    'name': '103-Miniature Directive Ant 10m',
    'imagePath': 'assets/images/103-Miniature_Directive_Ant_10m.jpg',
  },
  {
    'name': '104-Biquad Antenna 12dBi-Gain',
    'imagePath': 'assets/images/104-Biquad_Antenna_12dBi-Gain_2.jpg',
  },
  {
    'name': '105-Dual-Rhomboid Ant 435-870MHz',
    'imagePath': 'assets/images/105-Dual-Rhomboid_Ant_435-870MHz.jpg',
  },
  {
    'name': '106-Double-Bazooka Ant 80m',
    'imagePath': 'assets/images/106-Double-Bazooka_Ant_80m.jpg',
  },
  {'name': '107-J-Style Ant', 'imagePath': 'assets/images/107-J-Style_Ant.jpg'},
  {'name': '108-VHC Antenna', 'imagePath': 'assets/images/108-VHC_Antenna.jpg'},
  {
    'name': '109-Coax Inverted-L Ant 80m',
    'imagePath': 'assets/images/109-Coax_Inverted-L_Ant_80m.jpg',
  },
  {
    'name': '110-Indoor Compact Loop Ant 80m',
    'imagePath': 'assets/images/110-Indoor_Compact_Loop_Ant_80m.jpg',
  },
  {
    'name': '111-Helix Antenna',
    'imagePath': 'assets/images/111-Helix_Antenna.jpg',
  },
  {
    'name': '112-Novice Vertical Ant 80m-40m-15m-10m',
    'imagePath': 'assets/images/112-Novice_Vertical_Ant_80m-40m-15m-10m.jpg',
  },
  {
    'name': '113-Stub-Loaded Shortened Dipole 80m',
    'imagePath': 'assets/images/113-Stub-Loaded_Shortened_Dipole_80m.jpg',
  },
  {
    'name': '114-Six-Band Wire-Stub-Trap Ant 40m-10m',
    'imagePath': 'assets/images/114-Six-Band_Wire-Stub-Trap_Ant_40m-10m.jpg',
  },
  {
    'name': '115-Multiband Half-Wave Delta Loop',
    'imagePath': 'assets/images/115-Multiband_Half-Wave_Delta_Loop_.jpg',
  },
  {
    'name': '116-Hybrid Vee 20m-17m',
    'imagePath': 'assets/images/116-Hybrid_Vee_20m-17m.jpg',
  },
  {
    'name': '117-Six-Shooter Array Ant G-7',
    'imagePath': 'assets/images/117-Six-Shooter_Array_Ant_G-7.jpg',
  },
  {
    'name': '118-Multiband Ground Plane Ant 10-15-20m',
    'imagePath': 'assets/images/118-Multiband_Ground_Plane_Ant_10-15-20m.jpg',
  },
  {
    'name': '119-Wire Superbeam Ant 10-15-20m',
    'imagePath': 'assets/images/119-Wire_Superbeam_Ant_10-15-20m.jpg',
  },
  {
    'name': '120-Two Elements Delta Loop Ant',
    'imagePath': 'assets/images/120-Two_Elements_Delta_Loop_Ant.jpg',
  },
  {
    'name': '121-Sterba Curtain Ant',
    'imagePath': 'assets/images/121-Sterba_Curtain_Ant.jpg',
  },
  {
    'name': '122-Half-Wave Vertical Zepp Ant',
    'imagePath': 'assets/images/122-Half-Wave_Vertical_Zepp_Ant.jpg',
  },
  {
    'name': '123-Lazy-Loop Ant 40m',
    'imagePath': 'assets/images/123-Lazy-Loop_Ant_40m.jpg',
  },
  {
    'name': '124-Terminated Folded Dipole 80m-40m',
    'imagePath': 'assets/images/124-Terminated_Folded_Dipole_80m-40m.jpg',
  },
  {
    'name': '125-Short-Fat Ant 15m',
    'imagePath': 'assets/images/125-Short-Fat_Ant_15m.jpg',
  },
  {
    'name': '126-Cobra Ant 80m',
    'imagePath': 'assets/images/126-Cobra_Ant_80m.jpg',
  },
  {
    'name': '127-Log-Periodic Wire Ant 20m-15m-10m',
    'imagePath': 'assets/images/127-Log-Periodic_Wire_Ant_20m-15m-10m.jpg',
  },
  {
    'name': '128-5-element Log-Periodic Vertical Ant',
    'imagePath': 'assets/images/128-5-element_Log-Periodic_Vertical_Ant.jpg',
  },
  {
    'name': '129-2m Wire Vertical Antennas',
    'imagePath': 'assets/images/129-2m_Wire_Vertical_Antennas.jpg',
  },
  {
    'name': '130-Earth-Mover Inverted-V Ant 40m',
    'imagePath': 'assets/images/130-Earth-Mover_Inverted-V_Ant_40m.jpg',
  },
  {
    'name': '131-Coax-Cable Collinear Ant',
    'imagePath': 'assets/images/131-Coax-Cable_Collinear_Ant.jpg',
  },
  {
    'name': '132-Double Bobtail Ant 20m',
    'imagePath': 'assets/images/132-Double_Bobtail_Ant_20m.jpg',
  },
  {
    'name': '133-Collinear Zepp Ant',
    'imagePath': 'assets/images/133-Collinear_Zepp_Ant.jpg',
  },
  {
    'name': '134-Taylor Vee Ant 20m',
    'imagePath': 'assets/images/134-Taylor_Vee_Ant_20m.jpg',
  },
  {
    'name': '135-Collinear Vertical 6dB-Gain 2m',
    'imagePath': 'assets/images/135-Collinear_Vertical_6dB-Gain_2m1.jpg',
  },
  {
    'name': '136-Bi-Loop Antenna 20m',
    'imagePath': 'assets/images/136-Bi-Loop_Antenna_20m.jpg',
  },
  {
    'name': '137-Wire Beam 6dBd-Gain 10m',
    'imagePath': 'assets/images/137-Wire_Beam_6dBd-Gain_10m.jpg',
  },
  {
    'name': '138-Sloping Diamond Ant 4dB-Gain 40m',
    'imagePath': 'assets/images/138-Sloping_Diamond_Ant_4dB-Gain_40m.jpg',
  },
  {
    'name': '139-Twisted Loop Ant 160m',
    'imagePath': 'assets/images/139-Twisted_Loop_Ant_160m.jpg',
  },
  {
    'name': '140-DX RX Loop Ant 160m',
    'imagePath': 'assets/images/140-DX_RX_Loop_Ant_160m.jpg',
  },
  {
    'name': '141-Hentenna 3dB-Gain 10m-6m-2m',
    'imagePath': 'assets/images/141-Hentenna_3dB-Gain_10m-6m-2m.jpg',
  },
  {
    'name': '142-VK2AAR Wire Antenna 20m',
    'imagePath': 'assets/images/142-VK2AAR_Wire_Antenna_20m.jpg',
  },
  {
    'name': '143-2-Elem Quad Ant 6m',
    'imagePath': 'assets/images/143-2-Elem_Quad_Ant_6m.jpg',
  },
  {
    'name': '144-Hula-Loop Bidirectional 6dB-Gain Ant 17m',
    'imagePath':
        'assets/images/144-Hula-Loop_Bidirectional_6dB-Gain_Ant_17m.jpg',
  },
  {
    'name': '145-Moxon Rectangle Beam 15m-10m',
    'imagePath': 'assets/images/145-Moxon_Rectangle_Beam_15m-10m.jpg',
  },
  {
    'name': '146-Double-D Beam 4dB-Gain',
    'imagePath': 'assets/images/146-Double-D_Beam_4dB-Gain.jpg',
  },
  {
    'name': '147-KE4PT OCEF All-Band Dipole',
    'imagePath': 'assets/images/147-KE4PT_OCEF_All-Band_Dipole.jpg',
  },
  {
    'name': '148-Wire Quad Antenna for 40m',
    'imagePath': 'assets/images/148-Wire_Quad_Antenna_for_40m.jpg',
  },
  {
    'name': '149-Inclined Dipole 80m-40m',
    'imagePath': 'assets/images/149-Inclined_Dipole_80m-40m.jpg',
  },
  {
    'name': '150-Pyramidal Wire Antenna 80m',
    'imagePath': 'assets/images/150-Pyramidal_Wire_Antenna_80m.jpg',
  },
  {
    'name': '151-Random Wire Antenna All Bands',
    'imagePath': 'assets/images/151-Random_Wire_Antenna_All_Bands.jpg',
  },
  {
    'name': '152-Multiband Dipole Ant 80401510m',
    'imagePath': 'assets/images/152-Multiband_Dipole_Ant_80401510m.jpg',
  },
  {
    'name': '153-Slim Jim Wire Ant 4m',
    'imagePath': 'assets/images/153-Slim_Jim_Wire_Ant_4m.jpg',
  },
  {
    'name': '154-Delta Loop 6m',
    'imagePath': 'assets/images/154-Delta_Loop_6m.jpg',
  },
  {
    'name': '155-Re-Configurable Ant 160m80m',
    'imagePath': 'assets/images/155-Re-Configurable_Ant_160m80m.jpg',
  },
  {
    'name': '156-Very Low Frequency Inverted-L Ant',
    'imagePath': 'assets/images/156-Very_Low_Frequency_Inverted-L_Ant.jpg',
  },
  {
    'name': '157-Reduced Size Half Sloper Ant 160m',
    'imagePath': 'assets/images/157-Reduced_Size_Half_Sloper_Ant_160m.jpg',
  },
  {
    'name': '158-Tree-Mounted HF Antenna',
    'imagePath': 'assets/images/158-Tree-Mounted_HF_Antenna.jpg',
  },
  {
    'name': '159-Multiband Vertical Ant 80m 40m 20m',
    'imagePath': 'assets/images/159-Multiband_Vertical_Ant_80m_40m_20m.jpg',
  },
  {
    'name': '160-Marconi Antenna 136kHz',
    'imagePath': 'assets/images/160-Marconi_Antenna_136kHz.jpg',
  },
  {
    'name': '161-Simple Killer Antenna 40m',
    'imagePath': 'assets/images/161-Simple_Killer_Antenna_40m.jpg',
  },
  {
    'name': '162-Stub-Directed V Ant 80m',
    'imagePath': 'assets/images/162-Stub-Directed_V_Ant_80m.jpg',
  },
  {
    'name': '163-KT0NY Over-and Under DX Ant 20m',
    'imagePath': 'assets/images/163-KT0NY_Over-and_Under_DX_Ant_20m.jpg',
  },
  {
    'name': '164-Horizontal Loop Antenna',
    'imagePath': 'assets/images/164-Horizontal_Loop_Antenna.jpg',
  },
  {
    'name': '165-Ribbon J-Pole 2m',
    'imagePath': 'assets/images/165-Ribbon_J-Pole_2m.jpg',
  },
  {
    'name': '166-DualBand Ribbon J-Pole 2m 70cm',
    'imagePath': 'assets/images/166-dualband_ribbon_j-pole_2m70cm.jpg',
  },
  {
    'name': '167-Square Vert Loop Ant 40m',
    'imagePath': 'assets/images/167-Square_Vert_Loop_Ant_40m.jpg',
  },
  {
    'name': '168-Tri-Band Quad Ant 20m-15m-10m',
    'imagePath': 'assets/images/168-Tri-Band_Quad_Ant_20m-15m-10m.jpg',
  },
  {
    'name': '169-3D-Quad Ant 80m-40m-20m-15m-10m',
    'imagePath': 'assets/images/169-3D-Quad_Ant_80m-40m-20m-15m-10m.jpg',
  },
  {
    'name': '170-Sloping Wire Ant 30m-20m-17m-15m-12m-10m',
    'imagePath':
        'assets/images/170-Sloping_Wire_Ant_30m-20m-17m-15m-12m-10m.jpg',
  },
  {
    'name': '171-Broadband Dipole Coax Resonator 80m',
    'imagePath': 'assets/images/171-Broadband_Dipole_Coax_Resonator_80m.jpg',
  },
  {
    'name': '172-Resonant Feedline Dipole 80m',
    'imagePath': 'assets/images/172-Resonant_Feedline_Dipole_80m.jpg',
  },
  {
    'name': '173-Dual-Band Loading Wire Ant 80m-30m',
    'imagePath': 'assets/images/173-Dual-Band_Loading_Wire_Ant_80m-30m.jpg',
  },
  {
    'name': '174-Stub Matching Antennas',
    'imagePath': 'assets/images/174-Stub_Matching_Antennas.jpg',
  },
  {
    'name': '175-J-Style Vertical Wire Ant 10m',
    'imagePath': 'assets/images/175-J-Style_Vertical_Wire_Ant_10m.jpg',
  },
  {
    'name': '176-Dual Band Vertical with Zepp Feeders 40m-20m',
    'imagePath':
        'assets/images/176-Dual_Band_Vertical_with_Zepp_Feeders_40m-20m.jpg',
  },
  {
    'name': '177-RCA Double Doublet 40m-to-12m',
    'imagePath': 'assets/images/177-RCA_Double_Doublet_40m-to-12m.jpg',
  },
  {
    'name': '178-RCA Spiderweb Antenna 40m-to-6m',
    'imagePath': 'assets/images/178-RCA_Spiderweb_Antenna_40m-to-6m.jpg',
  },
  {
    'name': '179-Folded Dipole with Shorted Straps',
    'imagePath': 'assets/images/179-Folded_Dipole_with_Shorted_Straps.jpg',
  },
  {
    'name': '180-Twin-Lead Marconi Ant 160m-80m',
    'imagePath': 'assets/images/180-Twin-Lead_Marconi_Ant_160m-80m.jpg',
  },
  {
    'name': '181-Broadband Ant L-4 Balun 80m',
    'imagePath': 'assets/images/181-Broadband_Ant_L-4_Balun_80m.jpg',
  },
  {
    'name': '182-3L-4 Folded Doublet Dual-Band',
    'imagePath': 'assets/images/182-3L-4_Folded_Doublet_Dual-Band.jpg',
  },
  {
    'name': '183-3L-4 Folded Doublet No-Switch Dual Band',
    'imagePath':
        'assets/images/183-3L-4_Folded_Doublet_No-Switch_Dual_Band.jpg',
  },
  {
    'name': '184-Wideband Omnidirectional Discone Antenna',
    'imagePath':
        'assets/images/184-Wideband_Omnidirectional_Discone_Antenna.jpg',
  },
  {
    'name': '185-Wideband Rhombic Ant 40m-to-10m',
    'imagePath': 'assets/images/185-Wideband_Rhombic_Ant_40m-to-10m.jpg',
  },
  {
    'name': '186-Pre-Cut Linear Array Ant 3dB-Gain 40m',
    'imagePath': 'assets/images/186-Pre-Cut_Linear_Array_Ant_3dB-Gain_40m.jpg',
  },
  {
    'name': '187-X-Array Ant 6dB-Gain 20m-15m-10m',
    'imagePath': 'assets/images/187-X-Array_Ant_6dB-Gain_20m-15m-10m.jpg',
  },
  {
    'name': '188-Double-Bruce Array Ant 5dB-Gain 20m-10m',
    'imagePath':
        'assets/images/188-Double-Bruce_Array_Ant_5dB-Gain_20m-10m.jpg',
  },
  {
    'name': '189-Bi-Square Broadside Array Ant 4dB-Gain 20m-15m-10m',
    'imagePath':
        'assets/images/189-Bi-Square_Broadside_Array_Ant_4dB-Gain_20m-15m-10m.jpg',
  },
  {
    'name': '190-Six-Shooter Broadside Array Ant 7',
    'imagePath': 'assets/images/190-Six-Shooter_Broadside_Array_Ant_7.jpg',
  },
  {
    'name': '191-Triplex Flat-Top Beam 4',
    'imagePath': 'assets/images/191-Triplex_Flat-Top_Beam_4.jpg',
  },
  {
    'name': '192-Dual-Band Tilt Ant 20m-10m',
    'imagePath': 'assets/images/192-Dual-Band_Tilt_Ant_20m-10m.jpg',
  },
  {
    'name': '193-Super Space Multiband Dipole 80m-to-10m',
    'imagePath':
        'assets/images/193-Super_Space_Multiband_Dipole_80m-to-10m.jpg',
  },
  {
    'name': '194-Bi-Square Beam Ant Gain-5',
    'imagePath': 'assets/images/194-Bi-Square_Beam_Ant_Gain-5.jpg',
  },
  {
    'name': '195-Cousin-of-G5RV Multiband Ant 40m-to-10m',
    'imagePath':
        'assets/images/195-Cousin-of-G5RV_Multiband_Ant_40m-to-10m.jpg',
  },
  {
    'name': '196-Cayman Quad Ant 20m',
    'imagePath': 'assets/images/196-Cayman_Quad_Ant_20m.jpg',
  },
  {
    'name': '197-Hentenna G-3dB with Bazooka Match 6m',
    'imagePath': 'assets/images/197-Hentenna_G-3dB_with_Bazooka_Match_6m.jpg',
  },
  {
    'name': '198-X-Beam G-3dB 20m',
    'imagePath': 'assets/images/198-X-Beam_G-3dB_20m.jpg',
  },
  {
    'name': '199-Twin-Delta Loop G-6dB 160m-80m-40m',
    'imagePath': 'assets/images/199-Twin-Delta_Loop_G-6dB_160m-80m-40m.jpg',
  },
  {
    'name': '200-Inverted-V Beam Ant 30m',
    'imagePath': 'assets/images/200-Inverted-V_Beam_Ant_30m.jpg',
  },
  // … Rest deiner Liste
];

class AntennaTypesPage extends StatelessWidget {
  const AntennaTypesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Antennentypen')),
      body: ListView.builder(
        itemCount: antennaTypes.length,
        itemBuilder: (context, index) {
          final item = antennaTypes[index];
          return ListTile(
            title: Text(item['name'] ?? 'Unbenannt'),
            trailing: Icon(Icons.image),
            onTap: () => _showImageDialog(context, item),
          );
        },
      ),
    );
  }

  void _showImageDialog(BuildContext context, Map<String, String> item) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            insetPadding: EdgeInsets.all(2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.asset(
                      item['imagePath']!,
                      fit: BoxFit.contain,
                      errorBuilder:
                          (context, error, stackTrace) => Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text('Bild nicht gefunden'),
                          ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    item['name'] ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Schließen'),
                ),
              ],
            ),
          ),
    );
  }
}
