CREATE TABLE IF NOT EXISTS `vhs_playerstores` (
  `store_id` varchar(64) NOT NULL,
  `store_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`store_data`)),
  PRIMARY KEY (`store_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
