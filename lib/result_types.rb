# THIS FILE WAS NOT MODIFED FOR FINDER API [except for special characters]

class ResultTypes

  CANCER = 'cancer'
  CHIP = 'chip'
  COBRA = 'cobra'
  HELP_W_MEDICARE = 'help'
  HIGH_RISK = 'highrisk'
  IHI = 'ihi'
  INDIAN = 'native'
  LTC_MEDICAID = 'ltcm'
  LTC_PRIVATE = 'licp' #TODO change to i (AFTER SEARCHING ALL SITE!!!)
  MEDICAID = 'medicaid'
  MEDICARE = 'medicare'
  PARENTS = 'parents'
  SMALL_BIZ_DOI = 'sbizdoi'
  SMALL_BIZ_PLAN = 'sbiz'
  SMALL_BIZ_TAX ='sbiztax'
  SPECIAL_OPTIONS_IHI = 'soihi'
  SPOUSE = 'spouse'
  SUPPL_MEDICARE = 'suppl'
  VET = 'vet'
  WORK = 'work'
  SAFETYNET = 'safetynet'
  PACE = 'pace'

  def self.results_info
    ret = {}
    # ResultTypes::FREE_CARE = ['Finding care you can afford','There may be local facilities that provide free or reduced-cost care, whether you're insured or not. What you pay depends on your income.']
    ret[ResultTypes::CANCER]              = ['Breast and Cervical Cancer Prevention and Treatment Programs (BCCPT) through Medicaid', 'https://www.cms.gov/MedicaidSpecialCovCond/02_BreastandCervicalCancer_PreventionandTreatment.asp', 'These programs are available to eligible women diagnosed with breast and/or cervical cancer. Higher incomes may qualify.']
    ret[ResultTypes::CHIP]                = ['CHIP', nil, 'CHIP provides children and adults with low-cost insurance. Incomes up to about $45,000 a year (for a family of four) may qualify.']
    ret[ResultTypes::COBRA]               = ['COBRA Coverage', 'http://www.dol.gov/cobra', 'You may be able to keep the coverage you had at work for a limited time through a program called COBRA.']
    ret[ResultTypes::HELP_W_MEDICARE]     = ['Help with Your Medicare Costs', 'http://www.medicare.gov/navigation/medicare-basics/medical-and-drug-costs.aspx', 'If you have Medicare and a limited income, Medicaid and other programs may help pay for your Medicare costs.']
    ret[ResultTypes::HIGH_RISK]           = ['Pre-Existing Condition Insurance Plan (PCIP)/High Risk Pool', nil, 'You may qualify for a pre-existing condition insurance plan or a high risk pool, which helps people who have a hard time getting insurance find coverage.']
    ret[ResultTypes::IHI]                 = ['Health Insurance Plans for Individuals & Families', nil, 'If you do not have job-based or other coverage, you may want to buy a policy from a private insurer.']
    ret[ResultTypes::INDIAN]              = ['Indian Health Service', 'http://www.ihs.gov/index.cfm?module=AreaOffices', 'The Indian Health Service provides healthcare to members and descendants of American Indian and Alaska Native Tribes.']
    ret[ResultTypes::LTC_MEDICAID]        = ['Medicaid & Home and Community-Based Services Programs', 'http://www.nasmd.org/links/state_medicaid_links.asp', 'Medicaid helps pay for community-based long-term care and nursing home care for people with low incomes or high medical expenses.']
    ret[ResultTypes::LTC_PRIVATE]         = ['Private long-term care insurance', 'http://www.longtermcare.gov/LTC/Main_Site/Paying/Private_Financing/LTC_Insurance/Index.aspx', 'Private long-term care insurance may help pay for many types of long-term care. Long-term care insurance can vary widely.']
    ret[ResultTypes::MEDICAID]            = ['Medicaid', nil, 'Medicaid provides coverage for low income children, families, the elderly, and people with disabilities.  Pregnant women may qualify with higher incomes.']
    # note: medicare is overwrittedn
    # disabled medicare needhelp should go to http://www.medicare.gov/LTCPlanning
    # sr medicare needhelp should go to http://www.medicare.gov/LTCPlanning
    # sr medicare learn http://www.medicare.gov/Publications/Pubs/pdf/11467.pdf
    ret[ResultTypes::MEDICARE]            = ['Medicare', 'http://www.medicare.gov/navigation/medicare-basics/medicare-basics-overview.aspx', 'Medicare covers people 65 and over and certain people under 65 with a disability, and people with end-stage renal disease.']
    ret[ResultTypes::PARENTS]             = ['Coverage for Young Adults Under Age 26', 'http://cciio.cms.gov/programs/marketreforms/youngadults/index.html', 'If your parent\'s insurance offers dependent coverage, you may be eligible to be covered on their policy until age 26.']
    ret[ResultTypes::SMALL_BIZ_DOI]       = ['Small Employer Plan', 'http://www.naic.org/state_web_map.htm', 'As a self-employed person, you can buy private small employer health insurance. To learn more, contact your State Insurance Department.']
    ret[ResultTypes::SMALL_BIZ_PLAN]      = ['Private Health Insurance Products for Small Groups', nil, 'Insurance companies that sell small employer products can\'t turn your business down based on your employees\' health.']
    ret[ResultTypes::SMALL_BIZ_TAX]       = ['Tax Credits for Small Employers','http://www.irs.gov/newsroom/article/0,,id=223666,00.html','The small business health care tax credit helps small business and small tax-exempt organizations afford the cost of covering their employees.']
    ret[ResultTypes::SPECIAL_OPTIONS_IHI] = ['Special Options for Individual Health Insurance', 'http://www.naic.org/state_web_map.htm', "If you're losing job-based coverage and meet other qualifications, you may be eligible for a HIPAA policy or a conversion policy. You may have other options."]
    ret[ResultTypes::SPOUSE]              = ['Special Enrollment in Spouse\'s Job-based Health Plan', 'http://www.dol.gov/ebsa/publications/yhphipaa.html#4', 'If you involuntarily lose coverage, you may be eligible for a special opportunity to sign up for a job-based health plan.']
    ret[ResultTypes::SUPPL_MEDICARE]      = ['Medicare Supplemental Insurance (Medigap)', 'http://www.medicare.gov/medigap', 'Medicare Supplemental Insurance provides coverage for benefits not covered by Medicare.']
    # note: VET is overwrittedn
    # sr vet needhelp       http://www.vba.va.gov/bln/21/pension/vetpen.htm#7
    # disabled vet needhelp http://www.vba.va.gov/bln/21/pension/vetpen.htm#7
    ret[ResultTypes::VET]                 = ['Veterans Affairs', 'http://www4.va.gov/healtheligibility/', 'The Department of Veterans Affairs (VA) provides comprehensive healthcare and long-term care for veterans.']
    ret[ResultTypes::WORK]                = ['Health Insurance Through Work', 'http://www.dol.gov/ebsa/consumer_info_health.html', 'You may be eligible for coverage through work - your job or your spouse\'s.']
    ret[ResultTypes::SAFETYNET]           = ['Finding Care You Can Afford', 'http://www.hrsa.gov/gethealthcare/index.html', 'There may be local facilities that provide free or reduced-cost care, whether you\'re insured or not. What you pay depends on your income.']
    ret[ResultTypes::PACE]                = ['Programs of All-inclusive Care for the Elderly (PACE)', 'http://www.pace4you.org','PACE allows people age 55 or older who need nursing home-level of care to remain at home.  ']
    return ret
  end

end