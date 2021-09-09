import numpy as np
from numpy.fft import fft, fftshift, ifft
from obspy.signal.rotate import rotate_ne_rt
from obspy.core import Stream
from obspy.core import AttribDict
from obspy.signal.rotate import rotate_ne_rt
from telewavesim import utils as ut
from telewavesim import wiggle as wg

def tf_from_xyz(trxyz, slow, pvh=False, vp=None, vs=None):
    """
    Function to generate transfer functions from displacement traces.

    Args:
        trxyz (obspy.stream):
            Obspy ``Stream`` object in cartesian coordinate system
        pvh (bool, optional):
            Whether to rotate from Z-R-T coordinate system to P-SV-SH wave mode
        vp (float, optional):
            Vp velocity at surface for rotation to P-SV-SH system
        vs (float, optional):
            Vs velocity at surface for rotation to P-SV-SH system

    Returns:
        (obspy.stream):
            tfs: Stream containing Radial and Transverse transfer functions

    """

    # Extract East, North and Vertical
    ntr = trxyz[0]
    etr = trxyz[1]
    ztr = trxyz[2]
    baz = ntr.stats.baz
    wvtype = ntr.stats.wvtype

    # Copy to radial and transverse
    rtr = ntr.copy()
    ttr = etr.copy()

    # Rotate to radial and transverse
    rtr.data, ttr.data = rotate_ne_rt(ntr.data, etr.data, baz)

    if pvh:
        # vp = np.sqrt(cf.a[2,2,2,2,0])/1.e3
        # vs = np.sqrt(cf.a[1,2,1,2,0])/1.e3
        trP, trV, trH = rotate_zrt_pvh(ztr, rtr, ttr, slow, vp=vp, vs=vs)

        tfr = trV.copy()
        tfr.data = np.zeros(len(tfr.data))
        tft = trH.copy()
        tft.data = np.zeros(len(tft.data))
        ftfv = fft(trV.data)
        ftfh = fft(trH.data)
        ftfp = fft(trP.data)

        if wvtype == 'P':
            # Transfer function
            tfr.data = fftshift(np.real(ifft(np.divide(ftfv, ftfp))))
            tft.data = fftshift(np.real(ifft(np.divide(ftfh, ftfp))))
        elif wvtype == 'Si':
            tfr.data = fftshift(np.real(ifft(np.divide(-ftfp, ftfv))))
            tft.data = fftshift(np.real(ifft(np.divide(-ftfp, ftfh))))
        elif wvtype == 'SV':
            tfr.data = fftshift(np.real(ifft(np.divide(-ftfp, ftfv))))
        elif wvtype == 'SH':
            tft.data = fftshift(np.real(ifft(np.divide(-ftfp, ftfh))))
    else:
        tfr = rtr.copy()
        tfr.data = np.zeros(len(tfr.data))
        tft = ttr.copy()
        tft.data = np.zeros(len(tft.data))
        ftfr = fft(rtr.data)
        ftft = fft(ttr.data)
        ftfz = fft(ztr.data)

        if wvtype == 'P':
            # Transfer function
            tfr.data = fftshift(np.real(ifft(np.divide(ftfr, ftfz))))
            tft.data = fftshift(np.real(ifft(np.divide(ftft, ftfz))))
        elif wvtype == 'Si':
            tfr.data = fftshift(np.real(ifft(np.divide(-ftfz, ftfr))))
            tft.data = fftshift(np.real(ifft(np.divide(-ftfz, ftft))))
        elif wvtype == 'SV':
            tfr.data = fftshift(np.real(ifft(np.divide(-ftfz, ftfr))))
        elif wvtype == 'SH':
            tft.data = fftshift(np.real(ifft(np.divide(-ftfz, ftft))))

    # Store in stream
    tfs = Stream(traces=[tfr, tft])

    # Return stream
    return tfs
    
    
def rotate_zrt_pvh(trZ, trR, trT, slow, vp=6., vs=3.5):
    """
    Rotates traces from `Z-R-T` orientation to `P-SV-SH` wave mode.

    Args:
        trZ (obspy.trace): Vertical component
        trR (obspy.trace): Radial component
        trT (obspy.trace): Transverse component
        slow (float): slowness of wave
        vp (float, optional): P-wave velocity used for rotation
        vs (float, optional): S-wave velocity used for rotation

    Returns:
        (tuple): tuple containing:

            * trP (obspy.trace): Compressional (P) wave mode
            * trV (obspy.trace): Vertically polarized shear (SV) wave mode
            * trH (obspy.trace): Horizontally polarized shear (SH) wave mode

    """
    # Copy traces
    trP = trZ.copy()
    trV = trR.copy()
    trH = trT.copy()

    # Vertical slownesses
    qp = np.sqrt(1/vp**2 - slow**2)
    qs = np.sqrt(1/vs**2 - slow**2)

    # Elements of rotation matrix
    m11 = slow*vs*vs/vp
    m12 = -(1 - 2*vs*vs*slow*slow)/(2*vp*qp)
    m21 = (1 - 2*vs*vs*slow*slow)/(2*vs*qs)
    m22 = slow*vs

    # Rotation matrix
    rot = np.array([[-m11, m12], [-m21, m22]])

    # Vector of Radial and Vertical
    r_z = np.array([trR.data, trZ.data])

    # Rotation
    vec = np.dot(rot, r_z)

    # Extract P and SV components
    trP.data = vec[0, :]
    trV.data = vec[1, :]
    trH.data = -trT.data/2.

    return trP, trV, trH
    
# specify model file
#modfile = '/scratch/tolugboj_lab/Prj2_SEUS_RF/4_Bin/6_SYNTEST/TELEWAVEISM/SEUS_ModZ.txt'
modfile = '/scratch/tolugboj_lab/Prj4_Nomelt/seus_test/evan/model/sim.txt'

wvtype = 'P'

npts = 5000 # Number of samples
dt = 0.02 # Sample distance in seconds

# specify slowness/rayp file
ss = np.loadtxt('/scratch/tolugboj_lab/Prj4_Nomelt/seus_test/evan/rayP/linspace.txt')
# or give slowness/rayp here
#ss = np.arange(0.04, 0.08, 0.002)

baz = 0. # has no influence if model is isotropic

model = ut.read_model(modfile)

trR = Stream(); trT = Stream()

t1 = ut.calc_ttime(model, 0.06, wvtype=wvtype)
print('Predicted propagation time from model (slow = 0.06): {0:4.1f} sec'.format(t1))

# Loop over range of data
for slow in ss:
    # Calculate the plane waves seismograms    
    trxyz = ut.run_plane(model, slow, npts, dt,baz=baz, wvtype=wvtype)
    
    # Then the transfer functions in Z-R-T coordinate system
    tfs = ut.tf_from_xyz(trxyz, pvh=False)
    
    # Or in P-V-H, which requires surface velocities for rotation
    #tfs = tf_from_xyz(trxyz,slow, pvh=True, vp=6.70, vs=3.76) # for YY model
    #tfs = tf_from_xyz(trxyz,slow, pvh=True, vp=6.22, vs=3.57) # for ZZ model

    # Append to streams
    trR.append(tfs[0]); trT.append(tfs[1])

# Set frequency corners in Hz
f1 = 0.01
f2 = 2.00

# Filter plane waves seismograms
trR.filter('bandpass',freqmin=f1, freqmax=f2, corners=2, zerophase=True)
trT.filter('bandpass',freqmin=f1, freqmax=f2, corners=2, zerophase=True)

# Stack over all traces
trR_stack, trT_stack = ut.stack_all(trR, trT, pws=True)

# Save RFs
#modname = 'RF_ModY/SEUS_ModY_PSV'
modname = 'sac/sim' # change here

# Save seismograms
trR.write(modname+".R.sac",format="SAC")
trT.write(modname+".T.sac",format="SAC")
