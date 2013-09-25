require_relative 'result_types.rb'
require_relative 'situation_types.rb'
require_relative 'audience_types.rb'

module MapToXsd

	XPATH_BOOL_PREGNANT = "//PregnancyIndicator"
	XPATH_BOOL_DEPENDENTS = "//DependentUnder21Indicator"
	XPATH_BOOL_MEDICAL_CONDITION = "//MedicalConditionOrHealthProblemIndicator"
	XPATH_BOOL_DISABILITY = "//DisabilityIndicator"
	XPATH_BOOL_SPECIAL_NEED = "//SpecialHealthcareNeedIndicator"
	XPATH_BOOL_LTC = "//NursingHomeOrLongTermCareIndicator"
	XPATH_BOOL_NO_AFFORD  =  "//IsItDifficultForYouOrYourFamilyMemberToAffordInsuranceIndicator"
	XPATH_BOOL_CANCER = '//BreastOrCervicalCancerIndicator'
	XPATH_BOOL_VET = '//VeteranStatusIndicator'
	XPATH_BOOL_NATIVE = '//AmericanIndianOrAlaskanNativeIndicator'
	
	XPATH_SITUATION = '//Situation'
	
	AUDIENCE = {
		AudienceTypes::FAMILY => "FamilyAndChildrenAudienceRequest",
		AudienceTypes::HEALTHY => "HealthyIndividualAudienceRequest",
		AudienceTypes::MEDICAL_CONDITION => "IndividualWithMedicalConditionAudienceRequest",
		AudienceTypes::PREGNANT => "PregnantWomanAudienceRequest",
		AudienceTypes::DISABLED => "PersonWithDisabilityAudienceRequest",
		AudienceTypes::SENIOR => "SeniorAudienceRequest",
		AudienceTypes::YOUNG_ADULT => "YoungAdultAudienceRequest",
		AudienceTypes::SMALL_BUSINESS => "SmallEmployerOrSelfEmployedAudienceRequest"	
	}
	
	SITUATIONS = {
		AudienceTypes::FAMILY => {
			SituationTypes::Family::LOSING =>		 "familylosingworkinsurance",
			SituationTypes::Family::REJECTED =>  "familyrejectedinsurance",
			SituationTypes::Family::NEED =>      "familyneedinsurance"
		},
		AudienceTypes::HEALTHY => {
			SituationTypes::Healthy::LOSING => "individuallosingworkinsurance",
			SituationTypes::Healthy::NEED =>   "individualneedinsurance"
		},
		AudienceTypes::MEDICAL_CONDITION => {
			SituationTypes::Medical_condition::LOSING => 		"medicallosingworkinsurance",
			SituationTypes::Medical_condition::REJECTED =>  "medicalrejectedinsurance",
			SituationTypes::Medical_condition::NEED =>      "medicalneedinsurance"
		},
		AudienceTypes::PREGNANT => {
			SituationTypes::Pregnant::LOSING => 	"pregnantlosingworkinsurance",
			SituationTypes::Pregnant::REJECTED => "pregnantrejectedinsurance",
			SituationTypes::Pregnant::NEED =>     "pregnantneedinsurance"
		},
		AudienceTypes::DISABLED => {
			SituationTypes::Disabled::LOSING =>		"disabilitylosingworkinsurance",                                          
			SituationTypes::Disabled::REJECTED => "disabilityrejectedinsurance",
			SituationTypes::Disabled::NEED =>     "disabilityneedinsurance",
			SituationTypes::Disabled::NEEDHELP => "disabilitylongtermcare"
		},	
		AudienceTypes::SENIOR => {
			SituationTypes::Senior::EXISTING =>				"seniorlearnaboutlaw",
			SituationTypes::Senior::DONOTHAVE =>      "seniorinsurancenomedicare",
			SituationTypes::Senior::LEARNMORE =>      "seniorinsurancebenefits",
			SituationTypes::Senior::MEDICARE =>       "seniorhowmedicare",
			SituationTypes::Senior::CANNOTAFFORD =>   "seniorcantafford",
			SituationTypes::Senior::NEEDHELP =>       "seniorlongtermcare"
		},
		AudienceTypes::YOUNG_ADULT => {
			SituationTypes::Young_adult::LOSINGUNIVERSITY =>  "studentlosingschoolinsurance",
			SituationTypes::Young_adult::LOSINGPARENT =>      "studentlosingparentalinsurance",
			SituationTypes::Young_adult::REJECTED =>          "studentrejectedcondition",
			SituationTypes::Young_adult::NEED =>              "studentneedinsurance"
		},
		AudienceTypes::SMALL_BUSINESS => {
			SituationTypes::Small_business::NEED => 					"employerinsurance",
			SituationTypes::Small_business::SELFEMPLOYED =>   "selfemployedinsurance"
		}
	}
	
	
end