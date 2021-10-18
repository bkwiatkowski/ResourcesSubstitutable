{ This unit defines the structure of the model. There are four functions. The
  first function, called counts, defines the number, names, and units of the
  model, the state variables, the process variables, the driver variables and
  the parameters. The second function, called processes, is the actual equations
  which make up the model. The third function, derivs, calculates the
  derivatives of state variables. And the fourth function, parcount, is used to
  automatically number the parameters consecutively. 
    The state variables, driver variables, process variables and parameters are
  all stored in global arrays, called stat, drive, proc, and par, respectively.
  The function counts accesses the global arrays directly but the other functions
  operate on copies of the global arrays. }
unit equations;

interface

uses  stypes, math, sysutils;

PROCEDURE counts;
PROCEDURE processes(time:double; dtime:double; var tdrive:drivearray;
                       var tpar:paramarray; var tstat:statearray;
                       var tproc:processarray; CalculateDiscrete:Boolean);
PROCEDURE derivs(t, drt:double; var tdrive:drivearray; var tpar:paramarray;
             var statevalue:yValueArray; VAR dydt:yValueArray);
function ParCount(processnum:integer) : integer;

var
  tproc:processarray;
  tstat:statearray;
  sensflag:boolean;
  newyear:Boolean = false;
  DayofYear: double = 0;
  h: array[1..4,1..4] of double;

implementation

uses frontend, calculate, options;

           { Do not make modifcations above this line. }
{*****************************************************************************}

{ This procedure defines the model. The number of parameters, state, driver and
  process variables are all set in this procedure. The model name, version
  number and time unit are also set here. This procedure accesses the global
  arrays containing the the parameters, state, driver and process variables and
  the global structure ModelDef directly, to save memory space. }
PROCEDURE counts;
var
 i,npar,CurrentProc:integer;
begin
{ Set the modelname, version and time unit. }
ModelDef.modelname := 'substitutable resource';
ModelDef.versionnumber := '1.0.0';
ModelDef.timeunit := 'day';
ModelDef.contactperson := 'Ed';
ModelDef.contactaddress1 := 'Ecosystems';
ModelDef.contactaddress2 := 'MBL';
ModelDef.contactaddress3 := 'Woods Hole';

{ Set the number of state variables in the model. The maximum number of state
  variables is maxstate, in unit stypes. }
ModelDef.numstate := 16;

{ Enter the name, units and symbol for each state variable. The maximum length
  of the state variable name is 17 characters and the maximum length for units
  and symbol is stringlength (specified in unit stypes) characters. }
 
 
with stat[1] do
 begin
    name:='Plant C';  units:='g C m-2';  symbol:='BC';
 end;
 
with stat[2] do
 begin
    name:='Plant N';  units:='g N m-2';  symbol:='BN';
 end;
 
with stat[3] do
 begin
    name:='Avail N 1';  units:='g N m-2';  symbol:='N1';
 end;
 
with stat[4] do
 begin
    name:='Avail N 2';  units:='g N m-2';  symbol:='N2';
 end;
 
with stat[5] do
 begin
    name:='Avail N 3';  units:='g N m-2';  symbol:='N3';
 end;
 
with stat[6] do
 begin
    name:='Avail N 4';  units:='g N m-2';  symbol:='N4';
 end;
 
with stat[7] do
 begin
    name:='Effort C';  units:='effort';  symbol:='VC';
 end;
 
with stat[8] do
 begin
    name:='Effort N';  units:='effort';  symbol:='VN';
 end;
 
with stat[9] do
 begin
    name:='sub effort 1';  units:='effort';  symbol:='v1';
 end;
 
with stat[10] do
 begin
    name:='sub effort 2';  units:='effort';  symbol:='v2';
 end;
 
with stat[11] do
 begin
    name:='sub effort 3';  units:='effort';  symbol:='v3';
 end;
 
with stat[12] do
 begin
    name:='sub effort 4';  units:='effort';  symbol:='v4';
 end;
 
with stat[13] do
 begin
    name:='Int up C';  units:='g C m-2 day-1';  symbol:='UCbar';
 end;
 
with stat[14] do
 begin
    name:='Int up N';  units:='g N m-2 day-1';  symbol:='UNbar';
 end;
 
with stat[15] do
 begin
    name:='Int rec C';  units:='g C m-2 day-1';  symbol:='RCbar';
 end;
 
with stat[16] do
 begin
    name:='Int rec N';  units:='g N m-2 day-1';  symbol:='RNbar';
 end;

{ Set the total number of processes in the model. The first numstate processes
  are the derivatives of the state variables. The maximum number of processes is
  maxparam, in unit stypes. }
ModelDef.numprocess := ModelDef.numstate + 29;

{ For each process, set proc[i].parameters equal to the number of parameters
  associated with that process, and set IsDiscrete to true or false. After each
  process, set the name, units, and symbol for all parameters associated with
  that process. Note that Parcount returns the total number of parameters in
  all previous processes. }
 
CurrentProc := ModelDef.numstate + 1;
With proc[CurrentProc] do
   begin
      name       := 'Photosynthesis';
      units       := 'g C m-2 day-1';
      symbol       := 'UC';
      parameters       := 4;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='max Ps';  units:='g C m-2 day-1';  symbol:='Pmax';
 end;
with par[npar + 2] do
 begin
    name:='half sat';  units:='MJ m-2 day-1';  symbol:='eta';
 end;
with par[npar + 3] do
 begin
    name:='beers coef';  units:='m2 m-2';  symbol:='kI';
 end;
with par[npar + 4] do
 begin
    name:='spec leaf area';  units:='m-2 g-1 C';  symbol:='lambda';
 end;
 
CurrentProc := ModelDef.numstate + 2;
With proc[CurrentProc] do
   begin
      name       := 'Total N up';
      units       := 'g N m-2 day-1';
      symbol       := 'UN';
      parameters       := 0;
      ptype       := ptGroup1;
   end;
 
CurrentProc := ModelDef.numstate + 3;
With proc[CurrentProc] do
   begin
      name       := 'N up 1';
      units       := 'g N m-2 day-1';
      symbol       := 'UN1';
      parameters       := 2;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='N up rate 1';  units:='g N g-1 C day-1';  symbol:='gN1';
 end;
with par[npar + 2] do
 begin
    name:='half sat 1';  units:='g N m-2';  symbol:='kN1';
 end;
 
CurrentProc := ModelDef.numstate + 4;
With proc[CurrentProc] do
   begin
      name       := 'N up 2';
      units       := 'g N m-2 day-1';
      symbol       := 'UN2';
      parameters       := 2;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='N up rate 2';  units:='g N g-1 C day-1';  symbol:='gN2';
 end;
with par[npar + 2] do
 begin
    name:='half sat 2';  units:='g N m-2';  symbol:='kN2';
 end;
 
CurrentProc := ModelDef.numstate + 5;
With proc[CurrentProc] do
   begin
      name       := 'N up 3';
      units       := 'g N m-2 day-1';
      symbol       := 'UN3';
      parameters       := 2;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='N up rate 3';  units:='g N g-1 C day-1';  symbol:='gN3';
 end;
with par[npar + 2] do
 begin
    name:='half sat 3';  units:='g N m-2';  symbol:='kN3';
 end;
 
CurrentProc := ModelDef.numstate + 6;
With proc[CurrentProc] do
   begin
      name       := 'N up 4';
      units       := 'g N m-2 day-1';
      symbol       := 'UN4';
      parameters       := 2;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='N up rate 4';  units:='g N g-1 C day-1';  symbol:='gN4';
 end;
with par[npar + 2] do
 begin
    name:='half sat 4';  units:='g N m-2';  symbol:='kN4';
 end;
 
CurrentProc := ModelDef.numstate + 7;
With proc[CurrentProc] do
   begin
      name       := 'Respiration';
      units       := 'g C m-2 day-1';
      symbol       := 'RC';
      parameters       := 1;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='resp rate const';  units:='day-1';  symbol:='rmC';
 end;
 
CurrentProc := ModelDef.numstate + 8;
With proc[CurrentProc] do
   begin
      name       := 'C turnover';
      units       := 'g C m-2 day-1';
      symbol       := 'TC';
      parameters       := 1;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='C turnover rate const';  units:='day-1';  symbol:='mC';
 end;
 
CurrentProc := ModelDef.numstate + 9;
With proc[CurrentProc] do
   begin
      name       := 'N turnover';
      units       := 'g N m-2 day-1';
      symbol       := 'TN';
      parameters       := 1;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='N turnover rate const';  units:='day-1';  symbol:='mN';
 end;
 
CurrentProc := ModelDef.numstate + 10;
With proc[CurrentProc] do
   begin
      name       := 'PHI';
      units       := 'none';
      symbol       := 'PHI';
      parameters       := 4;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='acclim rate';  units:='day-1';  symbol:='a';
 end;
with par[npar + 2] do
 begin
    name:='sub acclim rate';  units:='day-1';  symbol:='omega';
 end;
with par[npar + 3] do
 begin
    name:='eps0';  units:='none';  symbol:='eps0';
 end;
with par[npar + 4] do
 begin
    name:='int const';  units:='day-1';  symbol:='rho';
 end;
 
CurrentProc := ModelDef.numstate + 11;
With proc[CurrentProc] do
   begin
      name       := 'psiC';
      units       := 'g C m-2 day-1';
      symbol       := 'psiC';
      parameters       := 0;
      ptype       := ptGroup1;
   end;
 
CurrentProc := ModelDef.numstate + 12;
With proc[CurrentProc] do
   begin
      name       := 'psiN';
      units       := 'g N m-2 day-1';
      symbol       := 'psiN';
      parameters       := 0;
      ptype       := ptGroup1;
   end;
 
CurrentProc := ModelDef.numstate + 13;
With proc[CurrentProc] do
   begin
      name       := 'allometry';
      units       := 'g C m-2';
      symbol       := 'S';
      parameters       := 2;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='alpha';  units:='m2 g-1 C';  symbol:='alpha';
 end;
with par[npar + 2] do
 begin
    name:='gamma';  units:='m2 g-1 C';  symbol:='gamma';
 end;
 
CurrentProc := ModelDef.numstate + 14;
With proc[CurrentProc] do
   begin
      name       := 'stoichiometry';
      units       := 'none';
      symbol       := 'THETA';
      parameters       := 1;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='opt C:N';  units:='g C g-1 N';  symbol:='qB';
 end;
 
CurrentProc := ModelDef.numstate + 15;
With proc[CurrentProc] do
   begin
      name       := 'max yield';
      units       := 'g N m-2 effort-1 day-1';
      symbol       := 'ymax';
      parameters       := 0;
      ptype       := ptGroup1;
   end;
 
CurrentProc := ModelDef.numstate + 16;
With proc[CurrentProc] do
   begin
      name       := 'beta';
      units       := 'none';
      symbol       := 'beta';
      parameters       := 0;
      ptype       := ptGroup1;
   end;
 
CurrentProc := ModelDef.numstate + 17;
With proc[CurrentProc] do
   begin
      name       := 'eps1';
      units       := 'effort';
      symbol       := 'eps1';
      parameters       := 0;
      ptype       := ptGroup1;
   end;
 
CurrentProc := ModelDef.numstate + 18;
With proc[CurrentProc] do
   begin
      name       := 'eps2';
      units       := 'effort';
      symbol       := 'eps2';
      parameters       := 0;
      ptype       := ptGroup1;
   end;
 
CurrentProc := ModelDef.numstate + 19;
With proc[CurrentProc] do
   begin
      name       := 'eps3';
      units       := 'effort';
      symbol       := 'eps3';
      parameters       := 0;
      ptype       := ptGroup1;
   end;
 
CurrentProc := ModelDef.numstate + 20;
With proc[CurrentProc] do
   begin
      name       := 'eps4';
      units       := 'effort';
      symbol       := 'eps4';
      parameters       := 0;
      ptype       := ptGroup1;
   end;
 
CurrentProc := ModelDef.numstate + 21;
With proc[CurrentProc] do
   begin
      name       := 'N leach 1';
      units       := 'g N m-2 day-1';
      symbol       := 'LN1';
      parameters       := 1;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='loss rate cosnt1';  units:='day-1';  symbol:='tau1';
 end;
 
CurrentProc := ModelDef.numstate + 22;
With proc[CurrentProc] do
   begin
      name       := 'N leach 2';
      units       := 'g N m-2 day-1';
      symbol       := 'LN2';
      parameters       := 1;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='loss rate cosnt2';  units:='day-1';  symbol:='tau2';
 end;
 
CurrentProc := ModelDef.numstate + 23;
With proc[CurrentProc] do
   begin
      name       := 'N leach 3';
      units       := 'g N m-2 day-1';
      symbol       := 'LN3';
      parameters       := 1;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='loss rate cosnt3';  units:='day-1';  symbol:='tau3';
 end;
 
CurrentProc := ModelDef.numstate + 24;
With proc[CurrentProc] do
   begin
      name       := 'N leach 4';
      units       := 'g N m-2 day-1';
      symbol       := 'LN4';
      parameters       := 1;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='loss rate cosnt4';  units:='day-1';  symbol:='tau4';
 end;
 
CurrentProc := ModelDef.numstate + 25;
With proc[CurrentProc] do
   begin
      name       := 'yeild 1';
      units       := 'g N m-2 effort-1 day-1';
      symbol       := 'y1';
      parameters       := 1;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='cost 1';  units:='g c g-1 N';  symbol:='phi1';
 end;
 
CurrentProc := ModelDef.numstate + 26;
With proc[CurrentProc] do
   begin
      name       := 'yeild 2';
      units       := 'g N m-2 effort-1 day-1';
      symbol       := 'y2';
      parameters       := 1;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='cost 2';  units:='g c g-1 N';  symbol:='phi2';
 end;
 
CurrentProc := ModelDef.numstate + 27;
With proc[CurrentProc] do
   begin
      name       := 'yeild 3';
      units       := 'g N m-2 effort-1 day-1';
      symbol       := 'y3';
      parameters       := 1;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='cost 3';  units:='g c g-1 N';  symbol:='phi3';
 end;
 
CurrentProc := ModelDef.numstate + 28;
With proc[CurrentProc] do
   begin
      name       := 'yeild 4';
      units       := 'g N m-2 effort-1 day-1';
      symbol       := 'y4';
      parameters       := 1;
      ptype       := ptGroup1;
   end;
npar:=ParCount(CurrentProc);
with par[npar + 1] do
 begin
    name:='cost 4';  units:='g c g-1 N';  symbol:='phi4';
 end;
 
CurrentProc := ModelDef.numstate + 29;
With proc[CurrentProc] do
   begin
      name       := 'dUCdVC';
      units       := 'g C m-2 day-1 effort-1';
      symbol       := 'dUCdVC';
      parameters       := 0;
      ptype       := ptGroup1;
   end;

{ Set the total number of drivers in the model. The maximum number of drivers is
  maxdrive, in unit stypes. }
ModelDef.numdrive := 5;

{ Set the names, units, and symbols of the drivers. The maximum length for the
  name, units and symbol is 20 characters. }
 
with drive[1] do
 begin
    name:='irradiance';  units:='MJ m-2 day-1';  symbol:='I';
 end;
 
with drive[2] do
 begin
    name:='N input 1';  units:='g N m-2 day-1';  symbol:='IN1';
 end;
 
with drive[3] do
 begin
    name:='N input 2';  units:='g N m-2 day-1';  symbol:='IN2';
 end;
 
with drive[4] do
 begin
    name:='N input 3';  units:='g N m-2 day-1';  symbol:='IN3';
 end;
 
with drive[5] do
 begin
    name:='N input 4';  units:='g N m-2 day-1';  symbol:='IN4';
 end;

{ The first numstate processes are the derivatives of the state variables. The
  code sets the names, units and symbols accordingly.}
for i:= 1 to ModelDef.numstate do proc[i].name:='d'+stat[i].name+'dt';
for i:= 1 to ModelDef.numstate do proc[i].units := stat[i].units + 't-1';
for i:= 1 to ModelDef.numstate do proc[i].symbol := 'd' + stat[i].symbol + 'dt';

{ Code to sum up the total number of parameters in the model. Do not change the
  next few lines. }
ModelDef.numparam := 0;
for i := 1 to ModelDef.NumProcess do
  ModelDef.numparam := ModelDef.numparam + proc[i].parameters;

end; // counts procedure


{ A procedure to calculate the value of all states and processes at the current
  time. This function accesses time, state variables and process variables by
  reference, ie it uses the same array as the calling routine. It does not use
  the global variables time, stat and proc because values calculated during
  integration might later be discarded. It does access the global variables par,
  drive and ModelDef directly because those values are not modified.

  The model equations are written using variable names which correspond to the
  actual name instead of using the global arrays (i.e. SoilWater instead of
  stat[7].value). This makes it necessary to switch all values into local
  variables, do all the calculations and then put everything back into the
  global variables. Lengthy but worth it in terms of readability of the code. }

// Choose either GlobalPs, ArcticPs, or none here so the appropriate Ps model is compiled below.
{$DEFINE none}

PROCEDURE processes(time:double; dtime:double; var tdrive:drivearray;
                       var tpar:paramarray; var tstat:statearray;
                       var tproc:processarray; CalculateDiscrete:Boolean);
{$IFDEF GlobalPs}
const
// Global Ps parameters
 x1 = 11.04;             x2 = 0.03;
 x5 = 0.216;             x6 = 0.6;
 x7 = 3.332;             x8 = 0.004;
 x9 = 1.549;             x10 = 1.156;
 gammastar = 0;          kCO2 = 995.4;  }
{$ENDIF}

// Modify constant above (line above "procedure processes..." line )to specify
// which Ps model and it's constants should be compiled. Choosing a Ps model
// automatically includes the Et and Misc constants (i.e. Gem is assumed).

{$IFDEF ArcticPs}
const
// Arctic Ps parameters
x1 = 0.192;	x2 = 0.125;
x5 = 2.196;	x6 = 50.41;
x7 = 0.161;	x8 = 14.78;
x9 = 1.146;
gammastar = 0.468;	kCO2 = 500.3;
{$ENDIF}

{$IFDEF ArcticPs OR GlobalPs}
//const
// General Et parameters
aE1 = 0.0004;    aE2 = 150;  aE3 = 1.21;   aE4 = 6.11262E5;

// Other constants
cp = 1.012E-9; //specific heat air MJ kg-1 oC-1
sigmaSB = 4.9e-9; //stefan-Boltzmann MJ m-2 day-1 K-4
S0 = 117.5; //solar constant MJ m-2 day-1
bHI1 =0.23;
bHI2 =0.48;
mw = 2.99; //kg h2o MJ-1
alphaMS = 2; //mm oC-1 day-1                                 }
{$ENDIF}

var
{ List the variable names you are going to use here. Generally, this list
  includes all the symbols you defined in the procedure counts above. The order
  in which you list them does not matter. }
{States}
BC, dBCdt, 
BN, dBNdt, 
N1, dN1dt, 
N2, dN2dt, 
N3, dN3dt, 
N4, dN4dt, 
VC, dVCdt, 
VN, dVNdt, 
v1, dv1dt, 
v2, dv2dt, 
v3, dv3dt, 
v4, dv4dt, 
UCbar, dUCbardt, 
UNbar, dUNbardt, 
RCbar, dRCbardt, 
RNbar, dRNbardt, 

{processes and associated parameters}
UC, Pmax, eta, kI, lambda, 
UN, 
UN1, gN1, kN1, 
UN2, gN2, kN2, 
UN3, gN3, kN3, 
UN4, gN4, kN4, 
RC, rmC, 
TC, mC, 
TN, mN, 
PHI, a, omega, eps0, rho, 
psiC, 
psiN, 
S, alpha, gamma, 
THETA, qB, 
ymax, 
beta, 
eps1, 
eps2, 
eps3, 
eps4, 
LN1, tau1, 
LN2, tau2, 
LN3, tau3, 
LN4, tau4, 
y1, phi1, 
y2, phi2, 
y3, phi3, 
y4, phi4, 
dUCdVC, 

{drivers}
I, 
IN1, 
IN2, 
IN3, 
IN4

{Other double}

:double; {Final double}

{Other integers}
npar, j, jj, kk, ll, tnum:integer;

{ Boolean Variables }


{ Functions or procedures }

begin
{ Copy the drivers from the global array, drive, into the local variables. }
I := tdrive[1].value;
IN1 := tdrive[2].value;
IN2 := tdrive[3].value;
IN3 := tdrive[4].value;
IN4 := tdrive[5].value;

{ Copy the state variables from the global array into the local variables. }
BC := tstat[1].value;
BN := tstat[2].value;
N1 := tstat[3].value;
N2 := tstat[4].value;
N3 := tstat[5].value;
N4 := tstat[6].value;
VC := tstat[7].value;
VN := tstat[8].value;
v1 := tstat[9].value;
v2 := tstat[10].value;
v3 := tstat[11].value;
v4 := tstat[12].value;
UCbar := tstat[13].value;
UNbar := tstat[14].value;
RCbar := tstat[15].value;
RNbar := tstat[16].value;

{ And now copy the parameters into the local variables. No need to copy the
  processes from the global array into local variables. Process values will be
  calculated by this procedure.

  Copy the parameters for each process separately using the function ParCount
  to keep track of the number of parameters in the preceeding processes.
  npar now contains the number of parameters in the preceding processes.
  copy the value of the first parameter of this process into it's local
  variable }
npar:=ParCount(ModelDef.numstate + 1);
Pmax := par[npar + 1].value;
eta := par[npar + 2].value;
kI := par[npar + 3].value;
lambda := par[npar + 4].value;

npar:=ParCount(ModelDef.numstate + 3);
gN1 := par[npar + 1].value;
kN1 := par[npar + 2].value;
 
npar:=ParCount(ModelDef.numstate + 4);
gN2 := par[npar + 1].value;
kN2 := par[npar + 2].value;
 
npar:=ParCount(ModelDef.numstate + 5);
gN3 := par[npar + 1].value;
kN3 := par[npar + 2].value;
 
npar:=ParCount(ModelDef.numstate + 6);
gN4 := par[npar + 1].value;
kN4 := par[npar + 2].value;
 
npar:=ParCount(ModelDef.numstate + 7);
rmC := par[npar + 1].value;
 
npar:=ParCount(ModelDef.numstate + 8);
mC := par[npar + 1].value;
 
npar:=ParCount(ModelDef.numstate + 9);
mN := par[npar + 1].value;
 
npar:=ParCount(ModelDef.numstate + 10);
a := par[npar + 1].value;
omega := par[npar + 2].value;
eps0 := par[npar + 3].value;
rho := par[npar + 4].value;
 
npar:=ParCount(ModelDef.numstate + 13);
alpha := par[npar + 1].value;
gamma := par[npar + 2].value;
 
npar:=ParCount(ModelDef.numstate + 14);
qB := par[npar + 1].value;
 
npar:=ParCount(ModelDef.numstate + 21);
tau1 := par[npar + 1].value;
 
npar:=ParCount(ModelDef.numstate + 22);
tau2 := par[npar + 1].value;
 
npar:=ParCount(ModelDef.numstate + 23);
tau3 := par[npar + 1].value;
 
npar:=ParCount(ModelDef.numstate + 24);
tau4 := par[npar + 1].value;
 
npar:=ParCount(ModelDef.numstate + 25);
phi1 := par[npar + 1].value;
 
npar:=ParCount(ModelDef.numstate + 26);
phi2 := par[npar + 1].value;
 
npar:=ParCount(ModelDef.numstate + 27);
phi3 := par[npar + 1].value;
 
npar:=ParCount(ModelDef.numstate + 28);
phi4 := par[npar + 1].value;
 
dBCdt := -999;
dBNdt := -999;
dN1dt := -999;
dN2dt := -999;
dN3dt := -999;
dN4dt := -999;
dVCdt := -999;
dVNdt := -999;
dv1dt := -999;
dv2dt := -999;
dv3dt := -999;
dv4dt := -999;
dUCbardt := -999;
dUNbardt := -999;
dRCbardt := -999;
dRNbardt := -999;
UC := -999;
UN := -999;
UN1 := -999;
UN2 := -999;
UN3 := -999;
UN4 := -999;
RC := -999;
TC := -999;
TN := -999;
PHI := -999;
psiC := -999;
psiN := -999;
S := -999;
THETA := -999;
ymax := -999;
beta := -999;
eps1 := -999;
eps2 := -999;
eps3 := -999;
eps4 := -999;
LN1 := -999;
LN2 := -999;
LN3 := -999;
LN4 := -999;
y1 := -999;
y2 := -999;
y3 := -999;
y4 := -999;
dUCdVC := -999;
 
{ Enter the equations to calculate the processes here, using the local variable
  names defined above. }


S:=VC+VN;
VC:=VC/S;
VN:=1-VC;
S:=v1+v2+v3+v4;
v1:=v1/S;
v2:=v2/S;
v3:=v3/S;
V4:=1-v1-v2-v3; 

S:=BC*((alpha*BC+1)/(gamma*BC+1));
THETA:=BC/qB/BN;
UC:=(Pmax/kI)*ln((eta+I)/(eta+I*exp(-kI*lambda*S*VC)));
UN1:=S*gN1*N1*VN*v1/(kN1+N1);
UN2:=S*gN2*N2*VN*v2/(kN2+N2);
UN3:=S*gN3*N3*VN*v3/(kN3+N3);
UN4:=S*gN4*N4*VN*v4/(kN4+N4);
UN:=UN1+UN2+UN3+UN4;
RC:=rmC*THETA*BC+phi1*UN1+phi2*UN2+phi3*UN3+phi4*UN4;
TC:=mC*BC;
TN:=mN*BN/THETA;
PHI:=power(UCbar/RCbar,VC)*power(UNbar/RNbar,VN);
psiC:=((rmC+mC)*BC+phi1*UN1+phi2*UN2+phi3*UN3+phi4*UN4)/THETA;
psiN:=mN*THETA*BN;
LN1:=tau1*N1;
LN2:=tau2*N2;
LN3:=tau3*N3;
LN4:=tau4*N4;
dUCdVC:=lambda*S*Pmax*I*exp(-kI*lambda*S*VC)/(eta+I*exp(-kI*lambda*S*VC)); 
y1:=S*gN1*N1*VN/(kN1+N1);
y1:=y1/(VN+y1*phi1/dUCdVC);
y2:=S*gN2*N2*VN/(kN2+N2);
y2:=y2/(VN+y2*phi2/dUCdVC);
y3:=S*gN3*N3*VN/(kN3+N3);
y3:=y3/(VN+y3*phi3/dUCdVC);
y4:=S*gN4*N4*VN/(kN4+N4);
y4:=y4/(VN+y4*phi4/dUCdVC);
ymax:=max(y1,max(y2,max(y3,y4)));
if y1=ymax then eps1:=eps0 else eps1:=0;
if y2=ymax then eps2:=eps0 else eps2:=0;
if y3=ymax then eps3:=eps0 else eps3:=0;
if y4=ymax then eps4:=eps0 else eps4:=0;
beta:=ymax*(max(v1,eps1)+max(v2,eps2)+max(v3,eps3)+max(v4,eps4));
beta:=(y1*max(v1,eps1)+y2*max(v2,eps2)+y3*max(v3,eps3)+y4*max(v4,eps4))/beta;
if CalculateDiscrete then
begin
// Add any discrete processes here
end; //discrete processes


{ Now calculate the derivatives of the state variables. If the holdConstant
  portion of the state variable is set to true then set the derivative equal to
  zero. }
if (tstat[1].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dBCdt := 0
else
 dBCdt := UC-TC-RC;
 
if (tstat[2].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dBNdt := 0
else
 dBNdt := UN-TN;
 
if (tstat[3].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dN1dt := 0
else
 dN1dt := IN1-UN1-LN1;
 
if (tstat[4].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dN2dt := 0
else
 dN2dt := IN2-UN2-LN2;
 
if (tstat[5].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dN3dt := 0
else
 dN3dt := IN3-UN3-LN3;
 
if (tstat[6].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dN4dt := 0
else
 dN4dt := IN4-UN4-LN4;
 
if (tstat[7].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dVCdt := 0
else
 dVCdt := a*ln(PHI*RCbar/UCbar)*VC;
 
if (tstat[8].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dVNdt := 0
else
 dVNdt := a*ln(PHI*RNbar/UNbar)*VN;
 
if (tstat[9].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dv1dt := 0
else
 dv1dt := omega*(y1/ymax-beta)*max(v1,eps1);
 
if (tstat[10].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dv2dt := 0
else
 dv2dt := omega*(y2/ymax-beta)*max(v2,eps2);
 
if (tstat[11].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dv3dt := 0
else
 dv3dt := omega*(y3/ymax-beta)*max(v3,eps3);
 
if (tstat[12].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dv4dt := 0
else
 dv4dt := omega*(y4/ymax-beta)*max(v4,eps4);
 
if (tstat[13].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dUCbardt := 0
else
 dUCbardt := rho*(UC-UCbar);
 
if (tstat[14].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dUNbardt := 0
else
 dUNbardt := rho*(UN-UNbar);
 
if (tstat[15].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dRCbardt := 0
else
 dRCbardt := rho*(psiC-RCbar);
 
if (tstat[16].HoldConstant) and (FmOptions.RunOptions.HoldStatesConstant) then
 dRNbardt := 0
else
 dRNbardt := rho*(psiN-RNbar);
 

{ Now that the calculations are complete, assign everything back into the arrays
  so the rest of the code can access the values calculated here. (Local variables
  are destroyed at the end of the procedure).

  Put the state variables back into the global arrays in case the state variable
  was manually changed in this procedure (e.g. discrete state variables or steady state
  calculations).   }
tstat[1].value := BC;
tstat[2].value := BN;
tstat[3].value := N1;
tstat[4].value := N2;
tstat[5].value := N3;
tstat[6].value := N4;
tstat[7].value := VC;
tstat[8].value := VN;
tstat[9].value := v1;
tstat[10].value := v2;
tstat[11].value := v3;
tstat[12].value := v4;
tstat[13].value := UCbar;
tstat[14].value := UNbar;
tstat[15].value := RCbar;
tstat[16].value := RNbar;

{  Put all process values into process variable array. The first numstate
  processes are the derivatives of the state variables (Calculated above).}
tproc[1].value := dBCdt;
tproc[2].value := dBNdt;
tproc[3].value := dN1dt;
tproc[4].value := dN2dt;
tproc[5].value := dN3dt;
tproc[6].value := dN4dt;
tproc[7].value := dVCdt;
tproc[8].value := dVNdt;
tproc[9].value := dv1dt;
tproc[10].value := dv2dt;
tproc[11].value := dv3dt;
tproc[12].value := dv4dt;
tproc[13].value := dUCbardt;
tproc[14].value := dUNbardt;
tproc[15].value := dRCbardt;
tproc[16].value := dRNbardt;

{ Now the remaining processes. Be sure to number the processes the same here as
  you did in the procedure counts above. }
tproc[ModelDef.numstate + 1].value := UC;
tproc[ModelDef.numstate + 2].value := UN;
tproc[ModelDef.numstate + 3].value := UN1;
tproc[ModelDef.numstate + 4].value := UN2;
tproc[ModelDef.numstate + 5].value := UN3;
tproc[ModelDef.numstate + 6].value := UN4;
tproc[ModelDef.numstate + 7].value := RC;
tproc[ModelDef.numstate + 8].value := TC;
tproc[ModelDef.numstate + 9].value := TN;
tproc[ModelDef.numstate + 10].value := PHI;
tproc[ModelDef.numstate + 11].value := psiC;
tproc[ModelDef.numstate + 12].value := psiN;
tproc[ModelDef.numstate + 13].value := S;
tproc[ModelDef.numstate + 14].value := THETA;
tproc[ModelDef.numstate + 15].value := ymax;
tproc[ModelDef.numstate + 16].value := beta;
tproc[ModelDef.numstate + 17].value := eps1;
tproc[ModelDef.numstate + 18].value := eps2;
tproc[ModelDef.numstate + 19].value := eps3;
tproc[ModelDef.numstate + 20].value := eps4;
tproc[ModelDef.numstate + 21].value := LN1;
tproc[ModelDef.numstate + 22].value := LN2;
tproc[ModelDef.numstate + 23].value := LN3;
tproc[ModelDef.numstate + 24].value := LN4;
tproc[ModelDef.numstate + 25].value := y1;
tproc[ModelDef.numstate + 26].value := y2;
tproc[ModelDef.numstate + 27].value := y3;
tproc[ModelDef.numstate + 28].value := y4;
tproc[ModelDef.numstate + 29].value := dUCdVC;

end;  // End of processes procedure


       { Do not make any modifications to code below this line. }
{****************************************************************************}


{This function counts the parameters in all processes less than processnum.}
function ParCount(processnum:integer) : integer;
var
 NumberofParams, counter : integer;
begin
  NumberofParams := 0;
  for counter := ModelDef.numstate + 1 to processnum - 1 do
         NumberofParams := NumberofParams + proc[counter].parameters;
  ParCount := NumberofParams;
end; // end of parcount function

{ This procedure supplies the derivatives of the state variables to the
  integrator. Since the integrator deals only with the values of the variables
  and not there names, units or the state field HoldConstant, this procedure
  copies the state values into a temporary state array and copies the value of
  HoldConstant into the temporary state array and passes this temporary state
  array to the procedure processes. }
PROCEDURE derivs(t, drt:double; var tdrive:drivearray; var tpar:paramarray;
             var statevalue:yValueArray; VAR dydt:yValueArray);
var
   i:integer;
   tempproc:processarray;
   tempstate:statearray;
begin
   tempstate := stat;  // Copy names, units and HoldConstant to tempstate
  // Copy current values of state variables into tempstate
   for i := 1 to ModelDef.numstate do tempstate[i].value := statevalue[i];
  // Calculate the process values
   processes(t, drt, tdrive, tpar, tempstate, tempproc, false);
  // Put process values into dydt array to get passed back to the integrator.
   for i:= 1 to ModelDef.numstate do dydt[i]:=tempproc[i].value;
end;  // end of derivs procedure

end.
