var Trip = window.Trip;
/*
steps: [
      {"element":".ow_status","intro":"status"}, 
      {"element":".ow_mailbox","intro":"mailbox"},
      {"element":".ow_test","intro":"test"}
   ].filter(function (obj) {
      return $(obj.element).length;
*/      

var survey_index = [
  { 
    sel : ".baseline_tab",
    header: "Baseline Surveys",
    content : "All your active baseline surveys are listed in this tab.",
    expose : true    
  },
  {
    sel : ".midline_tab",
    header: "Midline Surveys",
    content : "All your active midline surveys are listed in this tab.",
    expose : true    
  },
  {
    sel : ".drafts_tab",
    header: "Draft Surveys",
    content : "All your work in progress surveys, and surveys that are not published are listed here. Both draft baseline and midline surveys are listed here. If you copy or duplicate a survey, they appear in drafts.",
    expose : true    
  },
  {
    sel : ".expired_tab",
    header: "Expired Surveys",
    content : "All your surveys that are past the expiry date are published here. You can edit the survey to extend the expiry date if needed.",
    expose : true    
  },
  {
    sel : ".archived_tab",
    header: "Archived Surveys",
    content : "All your surveys that are purposely archived are placed in this tab. You can only use the reports, or duplicate an archived survey.",
    expose : true    
  },
  {
    sel : ".reports-link",
    header: "Reports",
    content : "You can click here to view reports. In the next screen, you will be requested to enter start and end date to view reports for the period.",
    expose : true    
  },
  {
    sel : ".col05",
    header: "Incomplete Responses",
    content : "The count of all incomplete records on the mobile is shown here. This number should ideally be very low.",
    expose : true    
  },
  {
    sel : ".organization_dashboards",
    header: "Survey Overview",
    content : "This provides an overview of productivity of users by date, number of complete and incomplete surveys per users, together with the last submitted dates.",
    expose : true    
  }  
];

var report_help = [
  {
    sel : ".go_btn",
    header: "View report",
    content : "You can select a desired date range of values, and view the different charts according to the data type of the report.",
    expose : true    
  },
  {
    sel : ".download_excel",
    header: "Download Excel",
    content : "You can select a desired date range of values, and download the Excel file. Report generation is an intensive process and it will take some time to provide the zip file for download.",
    expose : true    
  }    
  ];
  
var survey_build = [
  {
    sel : ".settingOptionsWrp",
    header: "Use settings",
    content : "You can mark a question as mandatory, or private or as an identifier using this option.",
    expose : true    
  },
  {
    sel : "#finalize",
    header: "Publish Survey",
    content : "Using this option will let you publish the survey. Many editing features will be restricted after the survey is published. Unless the survey is published, it is not available on the mobile device.",
    expose : true    
  },
  {
    sel : "#save",
    header: "Save Survey",
    content : "Using this option will let you let you save the survey as draft. All saved surveys can be found under the drafts menu.",
    expose : true    
  }  
  ];


function initTrip(help_text)
{
  var trip = new Trip(help_text.filter( function (obj) {
        return $(obj.sel).length;}),
  {
  showNavigation : true,
  showCloseBox : true,
  showHeader: true,
  tripTheme: "yeti",
  delay : -1
});

console.log(trip);
return trip; 
}

// Initialize the tour
function help(page){    
    var help_text;
    if(page == "survey_list")
    {
       help_text = survey_index;
    }
    if(page == "report_help")
    {
      help_text = report_help;
    }
    if(page == "survey_build")
    {
      help_text = survey_build;
    }
    
    if(help_text != "")
      initTrip(help_text).start();     
}
	