# THIS FILE WAS NOT MODIFED FOR FINDER API

module AudienceTypes
  
  FAMILY = "fam"
  HEALTHY = "hthy"
  MEDICAL_CONDITION = "cond"
  PREGNANT = "preg"
  DISABLED = "dsbl"
  SENIOR = "sr"
  YOUNG_ADULT = "ya"
  SMALL_BUSINESS = "sbiz"
  
  def self.age_ranges(audience_type)
    AgeRange.find(audience_info[audience_type][0])
  end
  
  def self.i_am(audience_type)
    audience_info[audience_type][1]
  end

  def self.radios(audience_type)
    audience_info[audience_type][2].map{|x| [x[0],x[1]]}
  end

  def self.offline_results(audience_type)
    ret = []
    audience_info[audience_type][2].each do |x|
      for r in x[2]
        ret.push r
      end
    end
    ret.push ResultTypes::VET
    ret.push ResultTypes::CANCER
    ret.push ResultTypes::INDIAN
    ret.push ResultTypes::SAFETYNET
    ret.uniq!
    return ret
  end
  
  def self.results(audience_type,situation_type)
    ret = nil
    audience_info[audience_type][2].each do |x|
      ret = x[2] if x[0] == situation_type
    end
    return ret
  end
  
  #TODO:this should be an accessor so it doesn't have to be built on each call!!!
  def self.audience_info
    ret = {}
    ret[AudienceTypes::FAMILY]=[
        [1,2,3,4],
        'Family',
        [[SituationTypes::Family::LOSING                ,"My family and I are losing the health insurance we have through work."                             ,[ResultTypes::PARENTS, ResultTypes::SPOUSE, ResultTypes::COBRA, ResultTypes::IHI, ResultTypes::SPECIAL_OPTIONS_IHI, ResultTypes::MEDICAID, ResultTypes::CHIP]],
        [SituationTypes::Family::REJECTED              ,"My family and I tried to get health insurance, but we were rejected for coverage."                 ,[ResultTypes::PARENTS, ResultTypes::MEDICAID, ResultTypes::CHIP]],
        [SituationTypes::Family::NEED                  ,"My family and I need health insurance for another reason."	                                        ,[ResultTypes::PARENTS, ResultTypes::WORK, ResultTypes::IHI, ResultTypes::MEDICAID, ResultTypes::CHIP]]
      ]]
    ret[AudienceTypes::SENIOR]=[ 
        [4],
        'Senior',                                                                                                                                          
        [[SituationTypes::Senior::EXISTING              ,"I have Medicare and want to learn how the new health law will help me."                            ,[ResultTypes::MEDICARE, ResultTypes::MEDICAID]],
        [SituationTypes::Senior::DONOTHAVE             ,"I don't have Medicare and want to learn about other health insurance options."                     ,[ResultTypes::MEDICAID, ResultTypes::IHI]],
        [SituationTypes::Senior::LEARNMORE             ,"I want to know more about insurance for benefits that are not covered by Medicare."                ,[ResultTypes::SUPPL_MEDICARE, ResultTypes::MEDICAID]],
        [SituationTypes::Senior::MEDICARE              ,"How do I get Medicare?"                                                                            ,[ResultTypes::MEDICARE, ResultTypes::MEDICAID]],
        [SituationTypes::Senior::CANNOTAFFORD          ,"I can't afford to pay for my costs under Medicare."                                                ,[ResultTypes::HELP_W_MEDICARE, ResultTypes::MEDICAID]],
        [SituationTypes::Senior::NEEDHELP              ,"I need help paying for long term care."	                                                          ,[ResultTypes::MEDICAID, ResultTypes::LTC_PRIVATE , ResultTypes::LTC_MEDICAID, ResultTypes::PACE, ResultTypes::MEDICARE]]
      ]]
    ret[AudienceTypes::SMALL_BUSINESS]=[  
        [],# no age range
        'Small Business',                                                                                                                                 
        [[SituationTypes::Small_business::NEED          ,"I need health insurance for my employees."                                                        ,[ResultTypes::SMALL_BIZ_PLAN, ResultTypes::SMALL_BIZ_TAX]],
        [SituationTypes::Small_business::SELFEMPLOYED  ,"I'm self-employed with no other employees."	                                                      ,[ResultTypes::SMALL_BIZ_DOI, ResultTypes::IHI]]
      ]]
    ret[AudienceTypes::YOUNG_ADULT]=[ 
        [1,2],
        'Young Adult (under 26)',                                                                                                                                     
        [[SituationTypes::Young_adult::LOSINGUNIVERSITY ,"I'm losing the student health insurance I had through my school"                                  ,[ResultTypes::PARENTS, ResultTypes::SPOUSE, ResultTypes::IHI, ResultTypes::MEDICAID, ResultTypes::CHIP]],
        [SituationTypes::Young_adult::LOSINGPARENT     ,"I'm losing the health insurance I had through work (or my parent's work)."                         ,[ResultTypes::PARENTS, ResultTypes::SPOUSE, ResultTypes::COBRA, ResultTypes::IHI, ResultTypes::SPECIAL_OPTIONS_IHI, ResultTypes::MEDICAID, ResultTypes::CHIP]],
        [SituationTypes::Young_adult::REJECTED         ,"I've tried to get health insurance, but I was rejected for coverage because I'm sick or disabled." ,[ResultTypes::PARENTS, ResultTypes::IHI, ResultTypes::MEDICAID, ResultTypes::CHIP]],
        [SituationTypes::Young_adult::NEED             ,"I need health insurance."	                                                                        ,[ResultTypes::PARENTS, ResultTypes::WORK, ResultTypes::IHI, ResultTypes::MEDICAID, ResultTypes::CHIP]]
      ]]
    ret[AudienceTypes::HEALTHY]=[
        [1,2,3,4],
        'Healthy Individual',                                                                                                                                          
        [[SituationTypes::Healthy::LOSING               ,"I'm losing the health insurance I have through work."                                              ,[ResultTypes::PARENTS, ResultTypes::SPOUSE, ResultTypes::COBRA, ResultTypes::IHI, ResultTypes::SPECIAL_OPTIONS_IHI, ResultTypes::MEDICAID, ResultTypes::CHIP]],
        [SituationTypes::Healthy::NEED                 ,"I need health insurance."	                                                                        ,[ResultTypes::PARENTS, ResultTypes::WORK, ResultTypes::IHI, ResultTypes::MEDICAID, ResultTypes::CHIP]]
      ]]
    ret[AudienceTypes::PREGNANT]=[
        [1,2,3],
        'Pregnant Woman',                                                                                                                                         
        [[SituationTypes::Pregnant::LOSING              ,"I'm losing the health insurance I had through work."                                               ,[ResultTypes::SPOUSE, ResultTypes::PARENTS, ResultTypes::COBRA, ResultTypes::IHI, ResultTypes::SPECIAL_OPTIONS_IHI, ResultTypes::MEDICAID, ResultTypes::CHIP]],
        [SituationTypes::Pregnant::REJECTED            ,"I've tried to get health insurance, but I was rejected for coverage because I'm pregnant."         ,[ResultTypes::MEDICAID, ResultTypes::CHIP, ResultTypes::IHI, ResultTypes::PARENTS]],
        [SituationTypes::Pregnant::NEED                ,"I need health insurance that will cover my pregnancy."	                                            ,[ResultTypes::MEDICAID, ResultTypes::CHIP, ResultTypes::WORK, ResultTypes::PARENTS, ResultTypes::IHI]]
      ]]
    ret[AudienceTypes::MEDICAL_CONDITION]=[
        [1,2,3,4],
        'Individual with Medical Condition',                                                                                                                                
        [[SituationTypes::Medical_condition::LOSING     ,"I'm losing the health insurance I had through work."                                                     ,[ResultTypes::PARENTS, ResultTypes::SPOUSE, ResultTypes::COBRA, ResultTypes::IHI, ResultTypes::SPECIAL_OPTIONS_IHI, ResultTypes::MEDICAID, ResultTypes::CHIP]],
        [SituationTypes::Medical_condition::REJECTED   ,"I've tried to get health insurance, but I was rejected for coverage because of my medical condition."     ,[ResultTypes::PARENTS, ResultTypes::IHI, ResultTypes::MEDICAID, ResultTypes::CHIP]],
        [SituationTypes::Medical_condition::NEED       ,"I need health insurance."	                                                                               ,[ResultTypes::PARENTS, ResultTypes::WORK, ResultTypes::IHI, ResultTypes::MEDICAID, ResultTypes::CHIP]]
      ]]
    ret[AudienceTypes::DISABLED]=[
        [1,2,3,4],
        'Person with Disability',                                                                                                                                        
        [[SituationTypes::Disabled::LOSING              ,"I'm losing the health insurance I had through work."                                               ,[ResultTypes::PARENTS, ResultTypes::SPOUSE, ResultTypes::COBRA, ResultTypes::IHI, ResultTypes::SPECIAL_OPTIONS_IHI, ResultTypes::MEDICAID, ResultTypes::MEDICARE, ResultTypes::CHIP]],
        [SituationTypes::Disabled::REJECTED            ,"I've tried to get health insurance, but I was rejected for coverage because of my disability."     ,[ResultTypes::PARENTS, ResultTypes::IHI, ResultTypes::MEDICAID, ResultTypes::MEDICARE, ResultTypes::CHIP]],
        [SituationTypes::Disabled::NEED                ,"I need health insurance."	                                                                        ,[ResultTypes::MEDICAID, ResultTypes::MEDICARE, ResultTypes::CHIP, ResultTypes::PARENTS, ResultTypes::WORK, ResultTypes::IHI]],
        # SHOULDNT LTC_PRIVAE BE THERE                                  
        [SituationTypes::Disabled::NEEDHELP            ,"I need help paying for long-term care."                                                            ,[ResultTypes::MEDICAID, ResultTypes::MEDICARE, ResultTypes::LTC_PRIVATE, ResultTypes::LTC_MEDICAID, ResultTypes::PACE]]
      ]]
    return ret
    
  end
  
end