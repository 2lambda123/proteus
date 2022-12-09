INTEGRATE_BY_PARTS_P = true

exp_factor = 12.7416
power_exp = -2.7845

diameter = 0.04
B_max = 0.5
u_avg = 0.01
dens = 870
dyn_visc = 9.4e-4
conduct = 2.6e6

scaled_dens = 1
scaled_dyn_visc = 1
scaled_conduct = 1

length_scaling_factor = ${fparse diameter / 100}
scaled_diameter = ${fparse diameter / length_scaling_factor}
length_scale_multiplier = ${fparse 1 / length_scaling_factor}

Ha = ${fparse B_max * diameter * sqrt(conduct/dyn_visc)}
Re = ${fparse u_avg * diameter * dens / dyn_visc}

scaled_B_max = ${fparse Ha / (scaled_diameter * sqrt(scaled_conduct/scaled_dyn_visc))}
scaled_u_avg = ${fparse Re / (scaled_diameter * scaled_dens / scaled_dyn_visc)}

[Mesh]
  [mesh]
    type = FileMeshGenerator
    file = nonuniform_B_mesh.e
  []
[]

[Variables]
  [velocity]
    family = LAGRANGE_VEC
    order = FIRST
  []
  [pressure]
    family = LAGRANGE
    order = FIRST
  []
  [electricPotential]
    family = LAGRANGE
    order = FIRST
  []
[]

[AuxVariables]
  [magneticField]
    family = LAGRANGE_VEC
    order = FIRST
  []
[]

[ICs]
  [velocityIC]
    type = VectorConstantIC
    x_value = 1e-15
    y_value = ${scaled_u_avg}
    z_value = 1e-15
    variable = velocity
  []
  [epotIC]
    type = ConstantIC
    value = 0
    variable = electricPotential
  []
[]

[BCs]
  [velocity_inlet]
    type = VectorFunctionDirichletBC
    variable = velocity
    boundary = inlet
    function = velocityFunction
  []
  [velocity_no_slip]
    type = VectorDirichletBC
    variable = velocity
    boundary = walls
    values = '0 0 0'
  []
  [pressure_reference]
    type = DirichletBC
    variable = pressure
    boundary = outlet
    value = 0
  []
  [epot_inlet]
    type = NeumannBC
    variable = electricPotential
    boundary = inlet
    value = 0
  []
  [epot_insulating_walls]
    type = NeumannBC
    variable = electricPotential
    boundary = 'inlet outlet walls'
    value = 0
  []
[]

[Materials]
  [const]
    type = ADGenericConstantMaterial
    prop_names =  'rho  mu        conductivity'
    prop_values = '${scaled_dens} ${scaled_dyn_visc} ${scaled_conduct}'
  []
  [irmins_mat_tau]
    type = IRMINSADTauMaterial
    velocity = velocity
    pressure = pressure
    magneticField = magneticField
    electricPotential = electricPotential
  []
[]

[Kernels]
  [mass]
    type = INSADMass
    variable = pressure
  []
  [mass_pspg]
    type = INSADMassPSPG
    variable = pressure
  []

  [momentum_convection]
    type = INSADMomentumAdvection
    variable = velocity
  []
  [momentum_viscous]
    type = INSADMomentumViscous
    variable = velocity
  []
  [momentum_pressure]
    type = INSADMomentumPressure
    variable = velocity
    pressure = pressure
    integrate_p_by_parts = ${INTEGRATE_BY_PARTS_P}
  []
  [momentum_supg]
    type = INSADMomentumSUPG
    variable = velocity
    velocity = velocity
  []
  [lorentz_force]
    type = IRMINSADMomentumLorentz
    variable = velocity
  []

  [epot_diffusion]
    type = ADDiffusion
    variable = electricPotential
  []
  [epot_production]
    type = IRMINSADElectricPotentialProduction
    variable = electricPotential
    velocity = velocity
    magneticField = magneticField
  []
[]

[AuxKernels]
  [magneticFieldKernel]
    type = VectorFunctionAux
    variable = magneticField
    function = magneticFieldFunction
    execute_on = INITIAL
  []
[]

[Functions]
  [velocityFunction]
    type = ParsedVectorFunction
    value_x = '0'
    value_y = '${scaled_u_avg}'
    value_z = '0'
  []
  [magneticFieldFunction]
    type = ParsedVectorFunction
    value_x = '0'
    value_y = '0'
    value_z = '${scaled_B_max}*pow((1.0 + exp(${exp_factor}*y*${length_scaling_factor})), ${power_exp})'
  []
[]

[Problem]
  type = FEProblem
[]

[Preconditioning]
  [SMP]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Steady
  solve_type = NEWTON
  automatic_scaling = true
  l_max_its = 100
  nl_max_its = 1000
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre    euclid'
[]

[Outputs]
  exodus = true
  execute_on = 'nonlinear'
[]
