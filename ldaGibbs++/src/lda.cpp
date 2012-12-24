/*
 * Copyright (C) 2007 by
 * 
 * 	Xuan-Hieu Phan
 *	hieuxuan@ecei.tohoku.ac.jp or pxhieu@gmail.com
 * 	Graduate School of Information Sciences
 * 	Tohoku University
 *
 * GibbsLDA++ is a free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published
 * by the Free Software Foundation; either version 2 of the License,
 * or (at your option) any later version.
 *
 * GibbsLDA++ is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with GibbsLDA++; if not, write to the Free Software Foundation,
 * Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.
 */

#include "model.h"
#include <stdio.h>

using namespace std;

void show_help();

int main(int argc, char ** argv) {
    model lda;

    // definition based on specified corpus (Ad-hoc setting)
    int train_docnum = 2500;
    int test_docnum = 2500;
    int dicnum = 12000;
    int headernum = 2;

    if (lda.init(argc, argv, dicnum, train_docnum, headernum)) {
	show_help();
	return 1;
    }
    
    if (lda.model_status == MODEL_STATUS_EST || lda.model_status == MODEL_STATUS_ESTC) {
	// parameter estimation
	lda.estimate();
    }
    
    if (lda.model_status == MODEL_STATUS_INF) {
	// do inference
	lda.inference();
    }
    
    return 0;
}

void show_help() {
    printf("Command line usage:\n");
    printf("\tlda -est -alpha <double> -beta <double> -ntopics <int> -niters <int> -savestep <int> -twords <int> -dfile <string>\n");
    printf("\tlda -estc -dir <string> -model <string> -niters <int> -savestep <int> -twords <int>\n");
    printf("\tlda -inf -dir <string> -model <string> -niters <int> -twords <int> -dfile <string>\n");
    // printf("\tlda -inf -dir <string> -model <string> -niters <int> -twords <int> -dfile <string> -withrawdata\n");
}

