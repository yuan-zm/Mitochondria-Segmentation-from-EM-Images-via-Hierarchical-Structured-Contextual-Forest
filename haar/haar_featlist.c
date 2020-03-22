
/*

  Haar features list parameters 

  Give all Haar features parameters for a Image I (ny x nx) and dictionary of Haar pattern given
  by rect_param

  Usage
  ------

  F = haar_featlist([ny] , [nx] , [rect_param]);

  
  Inputs
  ------

  ny                                    Number of rows of the pattern (default ny = 24)
  nx                                    Number of columns of the pattern (default nx = ny)
  rect_param                            Features rectangles parameters (10 x nR), where nR is the total number of rectangles for the patterns.
                                        (default Vertical(2 x 1) [1 ; -1] and Horizontal(1 x 2) [-1 , 1] patterns) 
										rect_param(: , i) = [if ; wp ; hp ; nrif ; nr ; xr ; yr ; wr ; hr ; sr], where
										if     index of the current Haar's feature. ip = [1,...,nF], where nF is the total number of Haar's features
										wp     width of the current rectangle pattern defining current Haar's feature
										hp     height of the current rectangle pattern defining current Haar's feature
										nrif   total number of rectangles for the current Haar's feature if
										nr     index of the current rectangle in the current Haar's feature, nr=[1,...,nrif]
										xr,yr  top-left coordinates of the current rectangle of the current Haar's feature
										wr,hr  width and height of the current rectangle of the current Haar's feature
										sr     weights of the current rectangle of the current Haar's feature 

										Please run gui_features_dictionary in the \gui subdir to build such parameters

  Output
  ------
  
  F                                     Features's list (6 x nF) in UINT32 where nF designs the total number of Haar features
                                        F(: , i) = [if ; xf ; yf ; wf ; hf ; ir]
										if     index of the current feature, if = [1,....,nF] where nF is the total number of Haar's features  (see nbfeat_haar function)
										xf,yf  top-left coordinates of the current Haar's feature
										wf,hf  width and height of the current feature Haar's feature
										ir     Linear index of the FIRST rectangle of the current Haar's feature according rect_param definition. 
										       ir is used internally in Haar function
										       (ir/10 + 1) is the matlab index of this first rectangle
 
*/

#include <math.h>
#include <mex.h>


/*-------------------------------------------------------------------------------------------------------------- */
/* Function prototypes */

int number_haar_features(int , int,int , double * , int );
void haar_featlist(int  , int ,int, double * , int  , unsigned int * );
/*-------------------------------------------------------------------------------------------------------------- */

void mexFunction( int nlhs, mxArray *plhs[] , int nrhs, const mxArray *prhs[] )
{
    int ny , nx, nz ;
	double	rect_param_default;
	double *rect_param;
	int nR = 4;
	long unsigned  int i, nF;
	unsigned int *F;
	int *dimsF;

    /* Input 1  */

    if ((nrhs > 0) && mxIsScalar(prhs[0]) )  
    {        
        ny        = (int) mxGetScalar(prhs[0]);  // get haar patch row       
    }
	if(ny < 3)
	{
		mexErrMsgTxt("ny must be >= 3");
	}
    
    /* Input 2  */
    
    if ((nrhs > 1) && mxIsScalar(prhs[1]) )
    {        
        nx        = (int) mxGetScalar(prhs[1]);  // get haar patch col 
		if(nx < 3)
		{
			mexErrMsgTxt("nx must be >= 3");		
		}
    }
	else
	{	
		nx        = ny;	
	}
	
	if ((nrhs > 2) && mxIsScalar(prhs[2]))
	{
		nz = (int)mxGetScalar(prhs[2]);  // get haar patch depth 
		if (nz < 3)
		{
			mexErrMsgTxt("nz must be >= 3");
		}
	}
	else
	{
		nz = ny;
	}

    if ((nrhs > 3) && !mxIsEmpty(prhs[3])  )
	{
		if(mxGetM(prhs[3]) != 13)
		{		
			mexErrMsgTxt("rect_param must be a (13 x nR) matrix");	
		}
		rect_param     = mxGetPr(prhs[3]);
		nR             = mxGetN(prhs[2]);
	}
	

	nF            = number_haar_features(ny , nx , nz, rect_param , nR);


	dimsF         = (int *)mxMalloc(2*sizeof(int));
	dimsF[0]      = 8;
	dimsF[1]      = nF;
	
	const mwSize  dimsFF[] = { 8, nF };

	plhs[0] = mxCreateNumericArray(2, dimsFF, mxINT32_CLASS, mxREAL);
	F             = (unsigned int *)mxGetPr(plhs[0]);

    /*------------------------ Main Call ----------------------------*/
        
	haar_featlist(ny , nx ,nz, rect_param , nR , F );

    /*------------------------ Free memory ----------------------------*/

	mxFree(dimsF);

    if ( (nrhs < 3) || mxIsEmpty(prhs[2]) )
	{
		mxFree(rect_param);
	}
}

/*---------------------------------------------------------------------------------------------- */
void haar_featlist(int ny , int nx , int nz ,double *rect_param , int nR , unsigned int *F )
{
	int  r , indF = 0 , indrect = 0 , currentfeat = 0 , temp , W , H , w , h , x , y,z,hw,hh,hd;
	int nx1 = nx + 1, ny1 = ny + 1, nz1 = nz + 1;
	
	for (r = 0 ; r < nR ; r++)
	{
		temp            = (int) rect_param[0 + indrect];	
		if(currentfeat != temp)
		{
			currentfeat = temp;
			hw           = (int) rect_param[1 + indrect];// rectangle width
			hh           = (int) rect_param[2 + indrect];// rectangle hight
			hd           = (int) rect_param[3 + indrect];// rectangle depth
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
		indrect        += 13;		
	}
}
/*------------------------------------------------------------------------------------------- */
int number_haar_features(int ny , int nx ,int nz, double *rect_param , int nR)
{
	int i , temp , indrect = 0 , currentfeat = 0 , nF = 0 , h , w,d;
	int Y , X ;	
	int nx1 = nx + 1, ny1 = ny + 1;
	
	for (i = 0 ; i < nR ; i++)
	{
		temp            = (int) rect_param[0 + indrect];
		if(currentfeat != temp)
		{
			currentfeat = temp;
			w           = (int) rect_param[1 + indrect];
			h           = (int) rect_param[2 + indrect];
			d           = (int) rect_param[3 + indrect];

			nF += (int)((nx - w + 1) * (ny - h + 1) * (nz - d + 1));
		}
		indrect   += 13;
	}
	return nF;
}

/*------------------------------------------------------------------------------------------ */
