
const { readFile, unlink } = require('fs'),
      { execSync, exec } = require('child_process'); 

interface Profile {
    first_name:string,
    last_name:string,
    email:string
}

interface SlackUser {
    name:string,
    id:string,
    deleted:boolean,
    profile:Profile,
}

interface SlackUsersResponseObject {
    ok:boolean,
    members:SlackUser[]
    error?:string
}

interface LookupTable {
    [key: string]: string
}

const lookupTable:LookupTable = {}

const NOTIFIER_BOT_TOKEN:string = process.argv[2] // First argument must be the NOTIFIER_BOT_TOKEN environment variable saved to this CircleCI project.

const slackUserInfoFilePath:string = 'slackUserInfo.json',
      getSlackUserShellScriptFilePath:string = 'src/scripts/get_slack_user_info.sh',
      writeLookupTableShellScriptFilePath:string = 'src/scripts/writeLookupTableToFile.sh',
      lookupTableFilePath:string = 'slackIdLookupTable.json'

// Execure the shell script that fetches the Slack user info.
execSync(`sh ${getSlackUserShellScriptFilePath} ${NOTIFIER_BOT_TOKEN}`);

// Parse the Slack user info to create the lookup table.
readFile(slackUserInfoFilePath, {encoding: 'utf-8'}, function(err:any, data:any){
    if (!err) {
        const slackUsersResponse:SlackUsersResponseObject = JSON.parse(data);
        if (!slackUsersResponse.ok) {
            console.log(`!!! Error - Response object not ok. Error: ${slackUsersResponse.error}`)
            return;
        }
        
        let slackUsers:SlackUser[] = slackUsersResponse.members;

        // Keep only non-deleted users that have first and last names.
        slackUsers = slackUsers.filter((slackUser:SlackUser) => {
            const userNotDeleted:boolean = !slackUser.deleted
            const userHasFirstAndLastName:boolean = !!slackUser.profile.first_name && !!slackUser.profile.last_name
            const userHasEmail:boolean = !!slackUser.profile.email

            const userIsReal:boolean = userNotDeleted && userHasFirstAndLastName && userHasEmail

            return userIsReal
        })
        
        // Populate the lookup table with name::id pairs.
        slackUsers.forEach((slackUser:SlackUser) => {
            let name:string = `${slackUser.profile.first_name.toLowerCase()}_${slackUser.profile.last_name.toLowerCase()}`.trim().replace(' ','_');
            name = name.replace(/_?\(.*\)_?/,'') // Remove "_(text)" from names that have them.
            name = name.replace('__','_') // Convert double underscores to single underscores.
            name = name.replace("'","") // Remove single quotes
            
            const id:string = slackUser.id;

            lookupTable[name] = id
        })

        // Execure the shell script that stores the lookup table in a file.
        exec(`sh ${writeLookupTableShellScriptFilePath} ${lookupTableFilePath} '${JSON.stringify(lookupTable)}'`, (error:any, stdout:any, stderr:any) => {
            if (error) {
              console.error(`exec error: ${error}`);
              return;
            }
            
            if (stdout) {
                console.log(`stdout: ${stdout}`);
            }

            if (stderr) {
                console.error(`stderr: ${stderr}`);
            }
          });
    } else {
        console.log(`!!! ERROR - ${err}`);
    }
});



// '{"sam_hodges":"UBWCQ2R9V","travis_hedge":"UBZ88S286","carrie_phillips":"UCLBD044R","evan_roman":"UDPSAK2BF","kelly_wulff":"UEJ5Z72N6","john_wallace":"UEPUQV1KN","scooter_sabel":"UFL7H2P5Y","anna_lee":"UGMQZNJHE","conor_mongey":"UGSQS5G64","ben_watts ":"UHHPHLN5S","rajat_kongovi":"UJJ9J2EFJ","candace_arterberry":"UM5U1HNNB","leah_headd":"UMUHD6HAA","david_kaufman":"UQ6834672","tony_thomson":"UQSU0AE75","nicole_hoops":"UR4CCHN2U","kai_hansen":"UR6A71341","drew_hylbert":"UR70HLLMB","morgan_faulkner":"URP09GSGY","dave_rafferty":"USY6R5TDX","deryck_reed":"UT8CDEAKF","django_whittington":"UTA7R8MQF","ximena_cervantes":"UU39NB5D5","cassidy_clawson":"U0109HNF7R6","warren_d'souza":"U014Z9EEVPS","jasmina_stritof":"U018LJSGZPE","heather_campbell":"U019N1H3Z6K","wes_joseph":"U01A3057SLR","zach_baumel":"U01A4JQK743","jerico_brewer":"U01FK8VTJ03","allison_schneider":"U01FMNA3CA2","kacie_altman":"U01GWG4Q5AS","amanda_sandoval":"U01HQBN1XPC","catherine_filus":"U01HRSY0Z7D","tyler_wheeler":"U01HRURJ7R7","amy_becht":"U01KM16RMMZ","damon_hastings":"U01M0UXTA30","colin_crook":"U01P2MN8FU2","lily_chan":"U01P6EKNUC8","denise_payton":"U01PMSYR4NM","greg_wilburn":"U01SKCVNYRM","maddie_arendsen":"U01SXT56G5S","chad_nitschke":"U01TB9EBDC1","sage_clements":"U01TCMQGLV7","tim_song":"U01TKEH34AX","milagros_ramirez":"U01UK8JHFDF","claire_cornell":"U01UX6C4TS7","jackie_watson":"U0202MKK34J","raphael_mastroianni":"U020QHJBEH5","blair_sheade":"U021B3WKK1V","ore_macaulay":"U022FHWMKLG","keri_brownell":"U0230A943H8","sabrina_reyes":"U023EBSCEAK","thomas_anglim":"U023NBG6LAJ","shaun_payne":"U023W7E7R8V","kourtney_steppe":"U026G0D7UJH","jira_asana_integration":"U026V86FKPE","zachary_friedlander":"U027JHD452B","justin_walters":"U027JLP7KAT","sameen_fatemi":"U027ZHE5MPD","nicole_seyk":"U0282D3SQ9G","kevin_watt":"U0284EQV3GF","sam_dalton":"U028G5YDMAR","joyce_calixto":"U028VDF2G6A","shuyu_wang":"U029J2F8SKX","daniel_chutich":"U029M6ZHCN7","george_aliaga":"U029RRT6ZCY","grace_sun":"U02B1RAT5RQ","marsella_lopez":"U02BD0PQTD1","allie_van_eaton":"U02CGKZ3E66","matthew_miller":"U02D68ZCY8G","martin_zegarelli":"U02DR6G5TPX","jason_mcfarland":"U02DU6TBXC3","dawson_blackhouse":"U02E0D2SF5J","yvonne_medellin":"U02F1AUMA9Z","mike_downey":"U02F7EH1S84","frank_rodriguez":"U02F7EHN0VA","jess_reid":"U02FZ7GTDL2","namah_vyakarnam":"U02H0DB1FCL","brandon_tuel":"U02JHH4M9B5","kristina_mlincsek":"U02L9E7BZB7","naila_eissa":"U02MACDT13J","lindsey_eselevsky":"U02MMFZ7LBE","eloise_jones":"U02MSD759FB","andrew_mcgill":"U02N3FK46Q0","eric_hsiao":"U02NSBV7KGF","borislava_avramova":"U02NSBWA9JT","george_hotarek":"U02P3KM3WLV","julie_bachtler":"U02PK70LANM","arnim_jain":"U02PKKR4665","katie_troy":"U02PWN9FS72","amanda_brown":"U02PWNA6U64","rukmini_banerjee":"U02QA4VBQJK","cody_carter":"U02RYGG07LN","hussein_al-kaf":"U02S56UNZT4","jordan_crider":"U02S57Y913M","nicholas_yacullo":"U02SUUFKCSU","sruti_balakrishnan":"U02UA3CKEMV","sidney_overman":"U02UHSJCLP8","kevin_mickan":"U02UMGE1X9B","john_schwartz":"U02UQDZSQAE","leah_langston":"U02UQHVPLUB","jay_schwartz":"U02V9LWSK2M","erin_faltin":"U0313FMTT9S","prith_gadhia":"U032ELSPC9H","maru_lango_barron":"U0334CXUA00","jeremy_lee":"U033UC95J7Q","okta_test":"U0356EP4F6F","nick_goupinets":"U035J1BL57Y","kassi_lanning":"U035QLCLV3L","david_santana":"U036EDA2U4Q","owen_gwilliam":"U036EDAE7CY","brianna_roppo_borghesi":"U036H6Z3JJ3","mariel_carranza":"U036HCP3DUP","kevin_weichel":"U036JSZVDCP","oscar_santiago":"U036K5AGABZ","satwant_singh":"U036V4YB0AZ","carrie_curtner":"U036Y0TQQD9","michael_phung":"U0371R8317E","chad_atherton":"U037QCT9S2C","oliver_ade":"U038LERNV39","katie_toomey":"U0392CU4Z44","jenny_nguyen":"U0392CUCS04","shaye_plunkett":"U0393D1QEKW","shalini_pimentel":"U039QRF7FU0","nell_hernandez":"U03AKBVKP5L","lyndall_wilson":"U03ATP0R5U2","mary_mahlman":"U03AUJHQC15","joanna_coleman":"U03BFPQKNPJ","emma_kako":"U03BLNESY58","zach_krueger":"U03BQ5QC68K","connor_hagan":"U03BQ5ZTWG3","kayti_mcrusso":"U03BSJZGTLL","lisa_hanson":"U03C9DUHM2M","kerri_devlin":"U03CU3HDYAJ","travis_hunziker":"U03CZEL8BM3","brant_morton":"U03D2B57ZCK","connie_wang":"U03EVASG9DY","rayann_chang":"U03EXMX6JJY","shreya_kati":"U03GMCE8G0J","nikki_hu":"U03GSD8E4TH","nate_dammerich":"U03H2SHHUP7","anna_roberts":"U03H702J6JE","emily_kessler":"U03H732P135","maddy_hoepf":"U03H74VE467","ken_toole":"U03H7UWGWDB","dan_telljohann":"U03HD7BUG7N","rebecca_mutek":"U03HD7PCTA8","joe_magdovitz":"U03JS0G600P","anita_norman":"U03K6GRUMHR","conor_dietzgen":"U03K91D4M0C","will_hawley":"U03K91KMD4L","jenna_allen":"U03M3T0HP0X","linda_horn":"U03M3T40A6B","omer_yetiskol":"U03MJFDRFDY","claire_opila":"U03N87XGB1N","steven_barge-siever":"U03PNCFNSLD","anthony_stevens":"U03PRAL2S66","matthew_rupert":"U03Q40FN2UR","emily_ekdahl":"U03QF3W5HTJ","jared_klee":"U03QF3ZBQ7J","sarina_sidhhanti":"U03QHKWF79D","kevin_tempel":"U03QVP9HZC6","travis_haddox":"U03S46ZF5RA","thang_bui":"U03TMHN4LDB","don_valdez":"U040G2BRDU7","patrick_baker":"U041LA92JN4","kellen_kincaid":"U041LQ819EK","thomas_wynne":"U042BCR4NJK","chris_maggio":"U042XHJ27D3","liam_greene":"U0434JAEQ01","alonzo_gomez":"U04366FC1FC","liam_green":"U043R13L7EC","christina_cook":"U045B04NR3L","alberto_gajano":"U045B06CP6E","jeison_aguilar":"U045PG005K3","brian_love":"U046VJ6N5HV","carissa_panke":"U048N24LF0E","harlan_seymour":"U049NJ5B7PH","ryan_belding":"U049NJBUXMM","sarah_cain":"U04A30AV4LA","vladimir_korshin":"U04A31V2RH9","asa_schachar":"U04ASQSSN3A","logan_mcdonald":"U04B12TEZJT","danielle_olgin":"U04C59U9QN4","hank_kinne":"U04D2SW9KL4","ez_habimana":"U04DD2CNF4Z","cole_smith":"U04F79M3PPX","nabeel_tanveer":"U04FH1H8KJ6","security_operations":"U04FPH5LDHC","jen_barry":"U04FW9FDN58","diana_silva":"U04FZUE5N80","emily_cocchiaro":"U04H2GK8P55","meg_glenn":"U04H544DQ8H","jade_wu":"U04HGLHQYRY","daniel_valenzuela":"U04HGPUK3EW","devin_wright":"U04HVH3RFRP","amy_singh":"U04HVKQBASD","ming_horn":"U04K7RZBNGL","alex_bruner":"U04M2JLUCN4","sara_lumetta":"U04M96YRK45","lara_klein":"U04N6PRMD37","melina_hollar":"U04NZD6ANQ0","will_rowan":"U04PDL06N58","brent_mcloughlin":"U04PG409M2Q","zorinne_green":"U04PS9S9QUR","rob_hamilton":"U04Q3AMA8TA","jacob_mainzer":"U04S5A8MR0B","bo_zhao":"U04S7TJUZ3N","sebastian_chen_schmidt":"U04S7URU9M2","brian_mulh":"U04SJ2XTBA5","elle_ayoub":"U04SVACR332","mike_kelly":"U04UCU0AQR5","sujit_konapur":"U050NQACWCX","jessica_bohn":"U051704LF45","steven_banks":"U05190KAZGR","sam_prohaska":"U053UT3Q1U2","alexi_belchere":"U054R5QNLFL","chelsea_fagan":"U05554218VC","tamika_gatson":"U056B3GQJ5V","adam_butler":"U056B6DHUGP","chris_poirier":"U056RBLQ2P5","marissa_cohen":"U056RH5NJE7","łukasz_rohde":"U056RS35SMV","mckay_warren":"U056Y3RR739","łukasz_reszke":"U056Z8K0Z1U","juslaine_thomas":"U0574AFSMPH","iris_funaioli":"U057E9C02LC","sarah_khan":"U0582QV83EU","chelsea_budde":"U0588503E6T","slack_automations":"U0588SRMUAE","mike_christensen":"U058FC2R0DU","sophie_mcnaught":"U058MTQ9AP4","mara_snyder":"U058QF6LKKN","daniel_gribbin":"U058ZHHBBPB","matt_ross":"U0591ACKH2M","marcin_kusiak":"U05AS64V10A","piotr_skoczylas":"U05B4QPHCRF","jonathan_grum":"U05BHACEAES","cierra_ramos":"U05BHG0DCBY","suzanne_robinson":"U05BQ0V6GUS","lindsay_kauchick":"U05BSCP86MA","vanessa_kuhlor":"U05BSJQC8KW","riz_watto":"U05EATLNA6B","monica_quach":"U05EJPVUWCE","damian_allen":"U05F6REFAKE","kelsey_hamon":"U05H1R548TF"}'