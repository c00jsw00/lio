 &INT0 
 TITLE = 'NO3',
 NATOM = 8, 
 NOPT = 0,
 NORM = T, 
 ANG = T, 
 EX = T, 
 COUL = F, 
 SCF1 = T, 
 PROP = F, 
 FIELD = F, 
 SOL = F, 
 RESP1 = F,
 &end
 6     0.000000     0.000000     0.000000
 1     0.000000     0.000000     1.089000
 1     1.026719     0.000000    -0.363000
 1    -0.513360     0.889165    -0.363000
 6    -0.683537    -1.183920    -0.483333
 1    -0.170177    -2.073085    -0.120333
 1    -0.683537    -1.183920    -1.572333
 1    -1.710256    -1.183920    -0.120333
gaussian
 8  15   6
 6 2 1 4 1 1
 0 0 0 1 1 2
   5222.9022000   -0.001936
    782.5399400   -0.014851
    177.2674300   -0.073319
     49.5166880   -0.245116
     15.6664400   -0.480285
      5.1793599   -0.335943
     10.6014410    0.078806
      0.9423170   -0.567695
      0.2774746    1.000000
     33.4241260    0.017560
      7.6221714    0.107630
      2.2382093    0.323526
      0.6867300    0.483223
      0.1938135    1.000000
      0.8000000    1.000000
 8 10 10
 1 1 1 1 1 1 1 1 1 1
 0 0 0 0 0 0 0 1 1 2
    628.6475400    1.000000
    143.9976180    1.000000
     40.0859040    1.000000
     11.9849376    1.000000
      1.4560475    1.000000
      4.7140760    1.000000
      0.4059979    1.000000
      4.7140760    1.000000
      0.4059979    1.000000
      1.0000000    1.000000
gaussian
 1   6   3
 4 1 1
 0 0 0
     50.9991780    0.0096604761
      7.4832181    0.073728860
      1.7774676    0.29585808
      0.5193295    0.71590532
      0.1541100    1.000000
      0.7500000    1.000000
 1 4 4
 1 1 1 1  1 1 1
 0 0 0 0  1 1 1
     45.0000000    1.000000
      7.5000000    1.000000
      0.3000000    1.000000
      1.5000000    1.000000
gaussian
 6  16   8
 5 2 1 1 4 1 1 1
 0 0 0 0 1 1 1 2
   1141.0227000    0.006147
    173.3805600    0.044978
     39.8344410    0.192275
     11.0053640    0.478681
      3.2369503    0.428463
      5.4905291   -0.077841
      0.4802485    0.563809
      0.6000000    1.000000
      0.1471999    1.000000
     18.9657530    0.014732
      4.3263115    0.089161
      1.2540734    0.292072
      0.3890520    0.493481
      0.1144014    1.000000
      0.0300000    1.000000
      0.6000000    1.000000
 6 10 10
 1 1 1 1 1 1 1 1 1 1
 0 0 0 0 0 0 0 1 1 2
    346.7611200    1.000000
     79.6688820    1.000000
     22.0107280    1.000000
      6.4739006    1.000000
      0.7781041    1.000000
      2.5081468    1.000000
      0.2288027    1.000000
      2.5081468    1.000000
      0.2288027    1.000000
      1.0000000    1.000000
endbasis
 &SCFINP
 OPEN = F, 
 NMAX=300
 NCO = 9,
 NUNP = 0, 
 ATRHO = F, 
 VCINP = F, 
 DIRECT = T, 
 EXTR = F, 
 SHFT = F, 
 SHI =  1., 
 IDAMP = 0, 
 GOLD =  5., 
 TOLD =  1.E-06, 
 WRITE = F, 
 MEMO = T, 
 &end 
 &EXCH 
 IEXCH = 3,
 INTEG = T, 
 DENS = T, 
 IGRID = 2, 
 IGRID2 = 1,
 &end 

