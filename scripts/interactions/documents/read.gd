extends Interaction

@export var viewer: Control = null
@export var sound: AudioStreamPlayer = null

@onready var text: String = (
	'КРАСЛАВСКАЯ ФЕДЕРАЦИЯ\n'
	+ 'КАПКАНСКАЯ ОБЛАСТЬ\n\n'
	+ 'РАСПОРЯЖЕНИЕ\n\n'
	+ 'О неотложных мерах по переселению граждан, проживающих на территории Металлургического '
	+ 'района г. Капканска, в связи с чрезвычайной ситуацией природного характера. '
	+ 'В связи с возникновением чрезвычайной сигуации природного характера, повлекшей за собой выброс в '
	+ 'атмосферный воздух неидентифицированного высокотоксичного газа (кодовое обозначение «В-04») '
	+ 'представляющего непосредственную угрозужизни и здоровью населения, и на основании заключения. '
	+ 'Межведомственной санитарно-химической комиссии № 42-СХ от «27» апреля 2011 года,\n\n'
	+ 'ПОСТАНОВЛЯЮ:\n\n'
	+ '1. Признать необходимым проведение немедленного, планового отселения и последующего '
	+ 'переселения граждан, постоянно или временно проживающих на территории Металлургического '
	+ 'района муниципального образования «Город Капканск» (далее - Зона Отселения).\n\n'
	+ '2. Утвердить границы Зоны Отселения согласно Приложению № 1 к настоящему распоряжению. '
	+ 'Установить, что нахождение граждан на территории Зоны Отселения запрещено с «28» апреля 2011 '
	+ 'года.\n\n'
	+ '3. Рекомендовать Главному управлению ММВД Краславии по Капканской области (тов. В.С. Громов) '
	+ 'обеспечить, совместно с воинскими подразделениями, охрану общественного порядка и соблюдение '
	+ 'пропускного режима на территории Зоны Отселения.\n\n'
	+ '4. Правлению жилищно-коммунального хозяйства (тов. А.И. Сазонов) в трехдневный срок: '
	+ '4.1. Определить перечень свободного жилого фонда, пригодного для временного размещения '
	+ 'переселенцев.\n\n'
	+ '4.2. Организовать предоставление гражданам, подлежащим переселению, жилых помещений '
	+ 'маневренного фонда в г. Капканске и прилегающих населенных пунктах.\n\n'
	+ '5. Департаменту здранаяранения (тов. Л.П. Орлова):\n\n'
	+ '5.1. Организовать проведение обязательного медицинского освидетельствования всех граждан, '
	+ 'подвергшихся воздействию газа «В-04».\n\n'
	+ '5.2. Обеспечить немедленную госпитализацию лиц с признаками острых и хронических '
	+ 'отравлений.\n\n'
	+ '6. Объявить, что отселение является временной мерой. Вопрос о сроках и условиях возвращения, а '
	+ 'также о коммпенсациях утраченного имущества будет рассмотрен специальной комиссией после '
	+ 'полной ликвидации угрозы и получения заключения о безопасности\n\n'
	+ '7. Контроль за исполнением настоящего распоряжения возложить на первого заместителя '
	+ 'губернатора Капканской области тов. П.К. Загорского.\n'
)

#@onready var text: String = (
	#"REPUBLIC OF KRASLAVIA\n"
	#+ "KAPKANSK REGION\n\n"
	#+ "ORDER\n\n"
	#+ "On urgent measures for relocating citizens residing in the Metallurgical District of the city of Kapkansk due to a natural emergency. "
	#+ "Due to the occurrence of a natural emergency that resulted in the release into the atmosphere of an unidentified highly toxic gas (code designation \"V-04\") posing an immediate threat to the life and health of the population, and based on the conclusion of the Interdepartmental Sanitary-Chemical Commission No. 42-SK dated \"27\" April 2011,\n\n"
	#+ "I ORDER:\n\n"
	#+ "1. To deem it necessary to carry out the immediate planned evacuation and subsequent relocation of citizens permanently or temporarily residing in the territory of the Metallurgical District of the municipal formation \"City of Kapkansk\" (hereinafter – the Evacuation Zone).\n\n"
	#+ "2. To approve the boundaries of the Evacuation Zone in accordance with Annex No. 1 to this order. Establish that presence of citizens within the Evacuation Zone is prohibited from \"28\" April 2011.\n\n"
	#+ "3. To recommend that the Main Directorate of the Ministry of Internal Affairs of Kraslavia for the Kapkansk Region (Comrade V.S. Gromov) ensure, together with military units, the protection of public order and enforcement of access control within the Evacuation Zone.\n\n"
	#+ "4. To the Housing and Communal Services Administration (Comrade A.I. Sazonov), within three days:\n"
	#+ "4.1. Determine the list of available housing stock suitable for temporary accommodation of evacuees.\n"
	#+ "4.2. Organize provision of housing from the maneuver fund in the city of Kapkansk and neighboring settlements to citizens subject to relocation.\n\n"
	#+ "5. To the Department of Health (Comrade L.P. Orlova):\n\n"
	#+ "5.1. Organize mandatory medical examinations of all citizens exposed to gas \"V-04\".\n\n"
	#+ "5.2. Ensure immediate hospitalization of persons showing signs of acute and chronic poisoning.\n\n"
	#+ "6. Announce that the evacuation is a temporary measure. The question of the timing and conditions of return, as well as compensation for lost property, will be considered by a special commission after the complete elimination of the threat and issuance of a safety conclusion.\n\n"
	#+ "7. Assign control over the implementation of this order to the First Deputy Governor of the Kapkansk Region, Comrade P.K. Zagorsky.\n"
#)

@onready var texture: Texture2D

func _ready() -> void:
	debug_name = 'Читать'

func interacte() -> void:
	if !sound.playing:
		sound.play()
	texture = load("res://textures/document0_low.png")
	viewer.texture.texture = texture
	viewer.label.text = text
	viewer.enter()
