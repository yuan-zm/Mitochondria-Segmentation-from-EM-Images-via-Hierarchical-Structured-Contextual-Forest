
#include <math.h>
#include <mex.h>

#ifdef OMP 
#include <omp.h>
#endif

#ifndef MAX_THREADS
#define MAX_THREADS 64
#endif

struct opts
{
	double        *rect_param;
	int            nR;

	unsigned int  *F;
	int            nF;

	int            standardize;
	int            usesingle;
	int            transpose;

#ifdef OMP 
	int            num_threads;
#endif
};

/*-------------------------------------------------------------------------------------------------------------- */

/* Function prototypes */

int number_haar_features(int, int, int, double *, int);
void haar_featlist(int, int, int, double *, int, unsigned int *);
void MakeIntegralImage(float *, float  *, int, int, int, float *);
float Area(float *, int, int, int, int, int, int, int, int);
void shaar(float *, int, int, int, int, struct opts, float *);

/*-------------------------------------------------------------------------------------------------------------- */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	float *I;
	const mwSize *dimsI;
	int numdimsI;
	struct opts options;
	long unsigned int i ,Nz, Ny, Nx, N = 1, tempint;
	double *zd, *tmp;
	float *zs;
	int numdimsz = 2;
	mwSize *dimsz;
	mwSize *dimszz;
	long unsigned  int a, b;
	mxArray *mxtemp;

	int cc_self;
	float temp_self;

	options.nR = 4;
	options.nF = 0;
	options.standardize = 0;
	options.usesingle = 1;
	options.transpose = 0;
#ifdef OMP 
	options.num_threads = -1;
#endif

	/* Input 1  */

	if ((nrhs > 0) && !mxIsEmpty(prhs[0]))// && mxIsUint8(prhs[0])
	{

		dimsI = mxGetDimensions(prhs[0]);
		numdimsI = mxGetNumberOfDimensions(prhs[0]);

		I = (float *)mxGetData(prhs[0]);

		Ny = dimsI[0]; // height of patch
		Nx = dimsI[1]; // width of patch
		Nz = dimsI[2]; // depth of patch
		if (numdimsI > 3)
		{
			N = dimsI[3]; //number of patch
		}
	}
	else
	{
		mexErrMsgTxt("I must be (Ny x Nx x N) in single format");
	}

	/* Input 2  */

	if ((nrhs > 1) && !mxIsEmpty(prhs[1]))
	{
		mxtemp = mxGetField(prhs[1], 0, "rect_param");
		if (mxtemp != NULL)
		{
			if (mxGetM(mxtemp) != 13)
			{
				mexErrMsgTxt("rect_param must be (13 x nR)");
			}

			options.rect_param = mxGetPr(mxtemp);
			options.nR = mxGetN(mxtemp);;
		}
		else
		{
			mexErrMsgTxt("rect_param is empty");
		}

		mxtemp = mxGetField(prhs[1], 0, "F");
		if (mxtemp != NULL)
		{
			options.F = (unsigned int *)mxGetData(mxtemp);
			options.nF = mxGetN(mxtemp);
		}
		else
		{
			mexErrMsgTxt("options.F is empty");
		}

		mxtemp = mxGetField(prhs[1], 0, "standardize");
		if (mxtemp != NULL)
		{
			tmp = mxGetPr(mxtemp);
			tempint = (int)tmp[0];
			if ((tempint < 0) || (tempint > 1))
			{
				mexPrintf("standardize = {0,1}, force to 1");
				options.standardize = 1;
			}
			else
			{
				options.standardize = tempint;
			}
		}

		mxtemp = mxGetField(prhs[1], 0, "usesingle");
		if (mxtemp != NULL)
		{
			tmp = mxGetPr(mxtemp);
			tempint = (int)tmp[0];

			if ((tempint < 0) || (tempint > 1))
			{
				mexPrintf("usesingle = {0,1}, force to 0");
				options.usesingle = 0;
			}
			else
			{
				options.usesingle = tempint;
			}
		}

		mxtemp = mxGetField(prhs[1], 0, "transpose");
		if (mxtemp != NULL)
		{
			tmp = mxGetPr(mxtemp);
			tempint = (int)tmp[0];

			if ((tempint < 0) || (tempint > 1))
			{
				mexPrintf("transpose = {0,1}, force to 0");
				options.transpose = 0;
			}
			else
			{
				options.transpose = tempint;
			}
		}
#ifdef OMP 

		mxtemp = mxGetField(prhs[1], 0, "num_threads");
		if (mxtemp != NULL)
		{
			tmp = mxGetPr(mxtemp);
			tempint = (int)tmp[0];
			if ((tempint < -2))
			{
				options.num_threads = -1;
			}
			else
			{
				options.num_threads = tempint;
			}
		}
#endif
	}
	else
	{
		mexErrMsgTxt("you must input something");
	}

	/*------------------------ Output ----------------------------*/
	if (options.transpose)
	{
		dimsz = (int *)mxMalloc(2 * sizeof(int));
		dimsz[0] = N;
		dimsz[1] = options.nF;

	}
	else
	{
		dimsz = (mwSize *)mxMalloc(2 * sizeof(mwSize));
		dimsz[0] = options.nF;
		dimsz[1] = N;
		
	}
	if (options.usesingle == 1)
	{
		plhs[0] = mxCreateNumericArray(numdimsz, dimsz, mxSINGLE_CLASS, mxREAL);
		zs = (float *)mxGetPr(plhs[0]);

		/*------------------------ Main Call ----------------------------*/
		shaar(I, Ny, Nx, Nz, N, options, zs);
	}
	else
	{
		mexPrintf("the input matrix must be single.");
	}
	/*----------------- Free Memory --------------------------------*/
	if ((nrhs > 1) && !mxIsEmpty(prhs[1]))
	{
		if ((mxGetField(prhs[1], 0, "rect_param")) == NULL)
		{
			mxFree(options.rect_param);
		}
		if ((mxGetField(prhs[1], 0, "F")) == NULL)
		{
			mxFree(options.F);
		}
	}
	else
	{
		mxFree(options.rect_param);
		mxFree(options.F);
	}
	mxFree(dimsz);
}
/*----------------------------------------------------------------------------------------------------------------------------------------- */

void shaar(float *I, int Ny, int Nx, int Nz, int P, struct opts options, float *out)
{
	double *rect_param = options.rect_param;
	unsigned int *F = options.F;
	int nF = options.nF, standardize = options.standardize, transpose = options.transpose;
#ifdef OMP 
	int num_threads = options.num_threads;
#endif
	int  p, indF, NxNy = Nx*Ny, NxNyNz = Nx*Ny*Nz, indNxNyNz = 0;
	int f, indnF = 0;
	int x, xr, y, yr, z,zr, w, wr, h, hr,d,dr ,i, r, R, indR;
	int coeffw, coeffh;
	int last;
	double val, s, var, mean, std, cteNxNy;
	float *II, *Itemp, tempI;

	II = (float *)malloc(NxNyNz*sizeof(float)); /////
	Itemp = (float *)malloc(NxNy*sizeof(float));

#ifdef OMP 
	num_threads = (num_threads == -1) ? min(MAX_THREADS, omp_get_num_procs()) : num_threads;
	omp_set_num_threads(num_threads);
#endif


	
		for (p = 0; p < P; p++)
		{
			indNxNyNz = p*NxNyNz; // get this calculate cubic start index
			indnF = p*nF;

			MakeIntegralImage(I + indNxNyNz, II, Nx, Ny, Nz, Itemp);

#ifdef OMP 
#pragma omp parallel for default(none) private(f,r,x,y,w,h,R,coeffw,coeffh,xr,yr,wr,hr,s) shared(transpose,p,P,z,II,F,rect_param,nF,Nx,Ny,std,indnF) reduction (*:indF)  reduction (+:val,indR) 
#endif
			for (f = 0; f < nF; f++)
			{
				indF = f * 8;
				x = F[1 + indF];
				y = F[2 + indF];
				z = F[3 + indF];
				w = F[4 + indF];
				h = F[5 + indF];
				d = F[6 + indF];
				indR = F[7 + indF];
				R = (int)rect_param[4 + indR]; // number of this pattern 
				val = 0.0;

				for (r = 0; r < R; r++)
				{
					// xr yr zr: top-left coordinates of the current cubic
					xr = x + (int)rect_param[6 + indR];
					yr = y + (int)rect_param[7 + indR];
					zr = z + (int)rect_param[8 + indR];
					// width height depth of current cubic
					wr = (int)(rect_param[9 + indR]);
					hr = (int)(rect_param[10 + indR]);
					dr = (int)(rect_param[11 + indR]);

					val = Area(II, xr, yr, zr, wr, hr, dr, Ny, NxNy);
					indR += 13;
				}
				if (transpose)
				{
					out[p + f*P] = val;
				}
				else
				{
					out[f + indnF] = val;
				}
			}
		}
	
	free(II);
	free(Itemp);
}
/*----------------------------------------------------------------------------------------------------------------------------------------- */
float Area(float *II, int x, int y, int z, int w, int h, int d, int Ny, int NxNy)
{
	// xr yr zr: top-left coordinates of the current cubic
	// width height depth of current cubic
    //val = Area(II, xr, yr, zr, wr, hr, dr, Ny);
	int h1 = h - 1, w1 = w - 1, d1 = d - 1, x1 = x - 1, y1 = y - 1, z1 = z - 1;

	if ((x == 0) && (y == 0) && (z == 0))
	{
		return ( II[  (x+w1)*Ny+(y+ h1) +(z+d1) * NxNy] );
	}
	if ((x == 0) && (y == 0) ) // here z ~= 0 
	{
		return (II[(x + w1)*Ny + (y + h1) + (z + d1) * NxNy] - II[(x + w1)*Ny + (y + h1) + z1 * NxNy]);
	}
	if ((y == 0) && (z == 0)) // here x ~= 0 
	{
		return (II[(x + w1)*Ny + (y + h1) + (z + d1)*NxNy] - II[x1 *Ny + (y + h1) + (z + d1)*NxNy ]);
	}

	if ((x == 0) && (z == 0)) // here y ~= 0 
	{
		return (II[(x + w1)*Ny + (y + h1) + (z + d1)*NxNy] - II[(x + w1)*Ny + y1 + (z + d1)*NxNy]);
	}
	if (z == 0) //
	{
		return (II[(x + w1)*Ny + (y + h1) + (z + d1)*NxNy] - II[x1*Ny + (y + w1) + (z + d1)*NxNy]
			- II[(x + h1)*Ny + y1 + (z + d1)*NxNy] + II[(x1*Ny) + y1 + (z + d1)*NxNy]);
	}
	if (y == 0) // h-d-g+c
	{
		return (II[(x + w1)*Ny + (y + h1) + (z + d1)*NxNy] - II[x1*Ny + (y + w1) + (z + d1)*NxNy]
			- II[(x + h1)*Ny + y + w1 + z1*NxNy] + II[x1*Ny + y + w1 + z1*NxNy]);
	}
	if (x == 0) // h-f-g+e
	{
		return (II[(x + w1)*Ny + (y + h1) + (z + d1)*NxNy] - II[(x + h1)*Ny + y1 + (z + d1)*NxNy]
			- II[(x + h1)*Ny + y + w1 + z1*NxNy] + II[(x + h1)*Ny + y1 + z1*NxNy]);
	}


	else{
		              //H - D - F - G+ B+ C +  E-A
		return (II[(x + w1)*Ny + (y + h1) + (z + d1)*NxNy] - II[x1*Ny + (y + w1) + (z + d1)*NxNy] 
			- II[(x + h1)*Ny + y1 + (z + d1)*NxNy] - II[(x + h1)*Ny + y + w1 + z1*NxNy]  
			+ II[(x1*Ny)+ y1 + (z + d1)*NxNy] + II[x1*Ny + y + w1 + z1*NxNy] + II[(x + h1)*Ny + y1 + z1*NxNy]
			- II[(x1*Ny + y1 + z1*NxNy)]);
	}


}
/*----------------------------------------------------------------------------------------------------------------------------------------- */
void haar_featlist(int ny, int nx, int nz, double *rect_param, int nR, unsigned int *F)
{

	int  r, indF = 0, indrect = 0, currentfeat = 0, temp, W, H, w, h, x, y, z, hw, hh, hd;
	int nx1 = nx + 1, ny1 = ny + 1, nz1 = nz + 1;

	for (r = 0; r < nR; r++)
	{
		temp = (int)rect_param[0 + indrect];
		if (currentfeat != temp)
		{
			currentfeat = temp;
			hw = (int)rect_param[1 + indrect];// rectangle width
			hh = (int)rect_param[2 + indrect];// rectangle hight
			hd = (int)rect_param[3 + indrect];// rectangle depth
			for (z = 0; z + hd < nz1; z++)
			{
				for (y = 0; y + hh < ny1; y++)
				{
					for (x = 0; x + hw < nx1; x++)
					{
						F[0 + indF] = currentfeat;
						F[1 + indF] = x;
						F[2 + indF] = y;
						F[3 + indF] = z;
						F[4 + indF] = hw;
						F[5 + indF] = hh;
						F[6 + indF] = hd;
						F[7 + indF] = indrect;
						indF += 8;
					}
				}
			}

		}
		indrect += 13;
	}
}
/*----------------------------------------------------------------------------------------------------------------------------------------- */
int number_haar_features(int ny, int nx, int nz , double *rect_param, int nR)
{
	int i, temp, indrect = 0, currentfeat = 0, nF = 0, h, w, d;
	int Y, X;
	int nx1 = nx + 1, ny1 = ny + 1;

	for (i = 0; i < nR; i++)
	{
		temp = (int)rect_param[0 + indrect];
		if (currentfeat != temp)
		{
			currentfeat = temp;
			w = (int)rect_param[1 + indrect];
			h = (int)rect_param[2 + indrect];
			d = (int)rect_param[3 + indrect];

			nF += (int)((nx - w + 1) * (ny - h + 1) * (nz - d + 1));
		}
		indrect += 13;
	}
	return nF;
}
/*----------------------------------------------------------------------------------------------------------------------------------------- */
void MakeIntegralImage(float *pIn, float *pOut, int iXmax, int iYmax, int iZmax, float *pTemp)
{
	// I don't let pTemp be empty when get through a z. Should test it!!!!!!!!
	/* Variable declaration */
	int x, y, z, t, indx, scaned = 0, NxNy = iXmax*iYmax;
	for (z = 0; z < iZmax; z++)
	{
		indx = 0; scaned = z * NxNy;
		for (x = 0; x < iXmax; x++)
		{
			pTemp[indx] = (float)pIn[indx + scaned];
			indx += iYmax;
		}
		for (y = 1; y < iYmax; y++)
		{
			pTemp[y] = pTemp[y - 1] + (float)pIn[y + scaned];
		}
		pOut[0 + scaned] = (float)pIn[0 + scaned];
		indx = iYmax;
		for (x = 1; x < iXmax; x++)
		{
			pOut[indx + scaned] = pOut[indx - iYmax + scaned] + pTemp[indx];
			indx += iYmax;
		}
		for (y = 1; y < iYmax; y++)
		{
			pOut[y + scaned] = pOut[y - 1 + scaned] + (float)pIn[y + scaned];
		}
		/* Calculate integral image */
		indx = iYmax;
		for (x = 1; x < iXmax; x++)
		{
			for (y = 1; y < iYmax; y++)
			{
				pTemp[y + indx] = pTemp[y - 1 + indx] + (float)pIn[y + indx + scaned];
				pOut[y + indx + scaned] = pOut[y + indx - iYmax + scaned] + pTemp[y + indx];
			}
			indx += iYmax;
		}
		if (z > 0){
			for (t = 0; t < NxNy; t++){
				pOut[t + scaned] = pOut[t + scaned - NxNy] + pOut[t + scaned];
			}
		}
	}
}
/*----------------------------------------------------------------------------------------------------------------------------------------------*/
